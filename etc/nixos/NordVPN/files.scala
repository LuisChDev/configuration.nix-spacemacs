//> using dep "com.lihaoyi::os-lib:0.9.0"
//> using dep "net.ruippeixotog::scala-scraper:3.0.0"
//> using dep "org.rogach::scallop:4.1.0"

import net.ruippeixotog.scalascraper.browser.JsoupBrowser
import net.ruippeixotog.scalascraper.dsl.DSL.*
import Extract.*
import Parse.*

import scala.sys.process.*
import org.rogach.scallop.*

class Conf(arguments: Seq[String]) extends ScallopConf(arguments):
  version("v0.1.0")
  banner("script construction in progress")
  val country = opt[String](descr = "select the country (using ISO codes), default co")
  val protocol = opt[String](descr = "select the protocol, default UDP")
  val action = trailArg[String](required = true)
  verify()

def menu(args: String*) =
  val conf = new Conf(args)
  conf.action() match
    case "connect" | "c" => throw new Exception("to be implemented")
    case "disconnect" | "d" => throw new Exception("to be implemented")
    case "generate" => ???
    case _ => println("see the docs")

def getOVPNFiles(dirPrefix: String = "/etc/nixos/NordVPN/") =
  val browser = JsoupBrowser()
  val doc = browser.get("https://nordvpn.com/ovpn/")
  val vpnsList = doc >> elementList(".List.List--custom")
  val links = (doc >> elementList(".Button.Button--primary.Button--small")).map(
    _ >> attr("href")
  )
  val getCountry =
    """https://downloads\.nordcdn\.com/configs/files/ovpn_legacy/servers/(\w{2})(\d+).nordvpn.com""".r

  val groupedLinks = links
    .drop(1)
    .groupBy(url => getCountry.findFirstMatchIn(url).map(_.group(1)))
    .removed(None)

  val udpstcps = groupedLinks.map { case (country, urls) =>
    (
      country,
      urls.zipWithIndex
        .foldLeft((Seq[String](), Seq[String]())) {
          case ((udps, tcps), (url, i)) =>
            if i % 2 == 0 then (udps.appended(url), tcps)
            else (udps, tcps.appended(url))
        }
    )
  }

  udpstcps.foreachEntry { case (country, (udps, tcps)) =>
    val baseDir = dirPrefix + "/" + country.get
    s"mkdir -p $baseDir $baseDir/udp $baseDir/tcp".!!

    udps.foreach(udp =>
      val serverNumber = getCountry.findFirstMatchIn(udp).map(_.group(2)).get
      s"curl $udp -o $baseDir/udp/$serverNumber".!!
      println(s"done downloading ${country.get} : $serverNumber - UDP")
    )

    tcps.foreach(tcp =>
      val serverNumber = getCountry.findFirstMatchIn(tcp).map(_.group(2)).get
      s"curl $tcp -o $baseDir/tcp/$serverNumber".!!
      println(s"done downloading ${country.get} : $serverNumber - TCP")
    )
  }

def patchFileAuthLoc(file: String, authLoc: String) =
  s"sed -i ':a;N;$$!ba;s/remote-cert-tls server\\n\\nauth-user-pass/auth-user-pass $authLoc \\n\\nremote-cert-tls server/' $file".!!
