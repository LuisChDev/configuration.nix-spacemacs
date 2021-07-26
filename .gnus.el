(setq user-mail-address "luischa123@gmail.com"
      user-full-name "Luis Eduardo Chavarriaga Cifuentes")

(add-to-list 'gnus-secondary-select-methods
             '(nnimap "Personal"
                      (nnimap-address "imap.gmail.com")
                      (nnimap-server-port "imaps")
                      (nnimap-stream ssl)))

(add-to-list 'gnus-secondary-select-methods
             '(nnimap "Empresa"
                      (nnimap-address "imap.gmail.com")
                      (nnimap-login "tomorrowtechofficial@gmail.com")
                      (nnimap-server-port "imaps")
                      (nnimap-stream ssl)))

(add-to-list 'gnus-secondary-select-methods
             '(nnimap "Profesional"
                      (nnimap-address "p3plzcpnl446378.prod.phx3.secureserver.net")
                      (nnimap-server-port "imaps")
                      (nnimap-stream ssl)))

(add-to-list 'gnus-secondary-select-methods
             '(nnimap "Universidad"
                      (nnimap-address "outlook.office365.com")
                      (nnimap-server-port "imaps")
                      (nnimap-stream ssl)))


(setq smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-sevice 587
      gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")

;; send email via Gmail
(setq send-mail-function 'smtpmail-send-it
      message-send-mail-function 'smtpmail-send-it
      smtpmail-default-smtp-server "smtp.gmail.com")

;; save outgoing mail in Sent folder
(setq gnus-message-archive-method '(nnimap "imap.gmail.com")
      gnus-message-archive-group "[Gmail]/Enviados")

;; set return email address based on incoming email address
(setq gnus-posting-styles
      '(
        ((header "to" "address@hotmail.com")
         (address "address@hotmail.com"))

        ((header "to" "address@gmail.com")
         (address "address@gmail.com"))
        )
      )

;; store email in ~/gmail directory
(setq nnml-directory "~/gmail")
(setq message-directory "~/gmail")



;; experimental, set SMTP automatically
;; Configure known SMTP servers. Emacs prompts for passwords and saves them in ~/.authinfo
(setq smtp-accounts          ;; Format: Sender Mail address - SMTP Server - Port - Username
      '(("luischa123@gmail.com" "smtp.gmail.com" 587 "luischa123@gmail.com")
        ("luis.chavarriaga@tomorrowrtech.com.co" "p3plzcpnl446378.prod.phx3.secureserver.net" 587 "luis.chavarriaga@tomorrowrtech.com.co")
        ("lchavarriaga@utb.edu.co" "outlook.office365.com" 587 "lchavarriaga@utb.edu.co")
        ("tomorrowtechofficial@gmail.com" "smtp.gmail.com" 587 "tomorrowtechofficial@gmail.com")
        ))

;; Set the SMTP Server according to the mail address we use for sending
(defun set-smtp-server-message-send-and-exit ()
  "Set SMTP server from list of multiple ones and send mail."
  (interactive)
  (message-remove-header "X-Message-SMTP-Method") ;; Remove. We always determine it by the From field
  (let ((sender
         (message-fetch-field "From")))
    (loop for (addr server port usr) in smtp-accounts
          when (string-match addr sender)
          do (message-add-header (format "X-Message-SMTP-Method: smtp %s %d %s" server port usr)))
    (let ((xmess
           (message-fetch-field "X-Message-SMTP-Method")))
      (if xmess
          (progn
            (message (format "Sending message using '%s' with config '%s'" sender xmess))
            (message-send-and-exit))
        (error "Could not find SMTP Server for this Sender address: %s. You might want to correct it or add it to the SMTP Server list 'smtp-accounts'" sender)))))

;; Send emails via multiple servers
(defun local-gnus-compose-mode ()
  "Keys."
  (local-set-key (kbd "C-c C-c")  'set-smtp-server-message-send-and-exit))

;; set in group mode hook
(add-hook 'gnus-message-setup-hook 'local-gnus-compose-mode)
