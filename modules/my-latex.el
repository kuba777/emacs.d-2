
(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)

(setq TeX-PDF-mode t)
(setq TeX-output-view-style
      (quote
       (("^pdf$" "." "evince -f %o"))))
(setq TeX-view-program-list '(("Evince" "evince --page-index=%(outpage) %o")))
(setq TeX-view-program-selection '((output-pdf "Evince")))

;;(setq TeX-source-correlate-start-server t)
;; (add-hook 'LaTeX-mode-hook '(lambda() (message "HU")
;; 			      (TeX-source-correlate-mode)
;; 			      (message "HU2")))

(add-hook 'LaTeX-mode-hook '(lambda() 
			      (define-key LaTeX-mode-map (kbd "C-c C-c") '(lambda() 
									    (interactive) 
									    (save-buffer)
									    (TeX-command "LaTeX" 'TeX-master-file)))))
;; dbus for reverse search (ctrl-mouse1 in evince to jump to position in emacs)
(require 'dbus)

(defun un-urlify (fname-or-url)
  "A trivial function that replaces a prefix of file:/// with just /."
  (if (string= (substring fname-or-url 0 8) "file:///")
      (substring fname-or-url 7)
    fname-or-url))

(defun th-evince-sync (file linecol &rest ignored)
  (let ((fname (url-unhex-string (un-urlify file)))
         ;; (buf (find-buffer-visiting fname))
	 ;; (buf (find-file-noselect fname))
         (line (car linecol))
         (col (cadr linecol)))
    (if (not (file-exists-p fname))
        (message "[Synctex]: %s is not opened..." fname)
      (find-file fname)
      (goto-line (car linecol))
      (unless (= col -1)
        (move-to-column col)))))

(defvar *dbus-evince-signal* nil)

(defun enable-evince-sync ()
  (when (and
         (eq window-system 'x)
         (fboundp 'dbus-register-signal))
    (unless *dbus-evince-signal*
      (setf *dbus-evince-signal*
            (dbus-register-signal
             :session nil "/org/gnome/evince/Window/0"
             "org.gnome.evince.Window" "SyncSource"
             'th-evince-sync)))))

(add-hook 'LaTeX-mode-hook 'enable-evince-sync)

(provide 'my-latex)
