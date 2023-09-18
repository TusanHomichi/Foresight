;;; loaded before user's ".emacs" file and default.el

;;; load ".el" files in "%(datadir)s/%(name)s/site-lisp/site-start.d/" on startup
;; (mapc 'load
;;       (directory-files "%(datadir)s/%(name)s/site-lisp/site-start.d"
;; 		       t "\\.el\\'"))
(mapc
 'load
 (delete-dups
  (mapcar 'file-name-sans-extension
          (directory-files
           "%(datadir)s/%(name)s/site-lisp/site-start.d" t "\\.elc?\\'"))))

;;; Emacs can use stock icons in the tool bar when compiled with Gtk+.
;;; However, this feature is disabled by default.  we enable it...
(setq icon-map-list '(x-gtk-stock-map))

;;; Defaults conary recipe files to Python mode
(setq auto-mode-alist
      (append (list '("\\.recipe\\'" . python-mode))
              auto-mode-alist))
