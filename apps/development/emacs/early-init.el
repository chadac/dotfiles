;;; package --- Summary
;;; Commentary:
;; (provide 'early-init)

;;; Code:

;; display
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-frame-parameter nil 'alpha-background 95)
(add-to-list 'default-frame-alist '(alpha-background . 95))

;; theme
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))
(load-theme 'vs2008 t)

;;; early-init.el ends here
