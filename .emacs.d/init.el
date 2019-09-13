;; Add cask
(require 'cask "~/.cask/cask.el")
(cask-initialize)

;; Add MELPA
(require 'package) ;; You might already have this line
;; (add-to-list 'package-archives
;;              '("melpa" . "https://melpa.org/packages/"))
;; (when (< emacs-major-version 24)
;;   ;; For important compatibility libraries like cl-lib
;;   (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

(setq exec-path (append exec-path '("~/.local/bin")))

(require 'cl)

;; Pallet for package management
(pallet-mode t)

;; Projectile mode
(projectile-global-mode)

;; Disable startup screen
(setq inhibit-startup-screen t)

;; Default tabs
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)
(defvaralias 'c-basic-offset 'tab-width)
(defvaralias 'cperl-indent-level 'tab-width)
(setq-default js-indent-level 2)
(setq-default css-indent-offset 2)
(setq-default web-mode-markup-indent-offset 2)
(setq-default web-mode-css-indent-offset 2)
(setq-default web-mode-code-indent-offset 2)

(smart-tabs-add-language-support c++ c++-mode-hook
  ((c-indent-line . c-basic-offset)
   (c-indent-region . c-basic-offset)))

;; Whitespaces
(require 'whitespace)
(setq whitespace-style '(face empty tabs lines-tail trailing))
(global-whitespace-mode t)

;; elpy
(use-package elpy
  :ensure t
  :init
  (elpy-enable))

(setq python-shell-interpreter "jupyter"
      python-shell-interpreter-args "console --simple-prompt"
      python-shell-prompt-detect-failure-warning nil)
(add-to-list 'python-shell-completion-native-disabled-interpreters
             "jupyter")

;; Based on http://stackoverflow.com/a/24373916
(defun adds-to-list (list elements)
  (interactive)
  (dolist (item elements) (add-to-list list item)))

;; File associations not added automatically
(adds-to-list 'auto-mode-alist
              '(("\\.tex\\'"      . latex-mode)
                ("\\.php\\'"      . web-mode)
                ("\\.html\\'"     . web-mode)
                ("\\.js[x]?\\'"   . web-mode)
                ("\\.m$"          . octave-mode)
                ("\\.yml\\'"      . yaml-mode)))

;; Theme
;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(custom-enabled-themes (quote (manoj-dark)))
;;  '(safe-local-variable-values (quote ((eval setq web-mode-content-types-alist (\` (("jsx" \, (concat default-directory ".*\\.js"))))) (eval setq web-mode-content-types-alist (quote (("jsx" . "\\.js[x]?\\"))))))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (use-package elpy yaml-mode web-mode smart-tabs-mode scss-mode sass-mode python-mode projectile php-mode pallet neotree markdown-mode lua-mode jdee helm haskell-mode groovy-mode gradle-mode go-mode gitignore-mode flappymacs ess-R-data-view ensime dockerfile-mode coffee-mode auctex))))
