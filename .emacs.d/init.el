;; Add LPA
(require 'package) ;; You might already have this line
(add-to-list
 'package-archives
 '("melpa" . "https://stable.melpa.org/packages/"))

(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents   (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(if (file-exists-p "./.emacs.d/init.local.el")
    (load-file "./.emacs.d/init.local.el"))

;; Require emacs to prompt when exiting
(setq confirm-kill-emacs 'yes-or-no-p)

;; Disable weird indentation
(electric-indent-mode -1)

;; Disable startup screen
(setq inhibit-startup-screen t)

;; Copy config
(setq backup-directory-alist `(("." . "~/.emacs.d/saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)

;; COMPANY-MODE
(use-package company
  :ensure t
  :bind (:map company-active-map
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous))
  :config
  (setq company-idle-delay 0.3)
  (global-company-mode t))

(use-package company-jedi
  :ensure t
  :config
  (add-to-list 'company-backends 'company-jedi))

;; APL
(use-package gnu-apl-mode
  :ensure t)

;; PROJECTILE
(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  ;; (setq projectile-project-search-path '(("~/code/" . 3)))
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map)))

;; MAGIT
(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

;; EVIL
;; evil-mode for vim editing
(use-package evil
  :ensure t
  :init
  :config
  (evil-mode))

;; Lsp-mode supports snippets, but in order for them to work you need to use yasnippet
;; If you don't want to use snippets set lsp-enable-snippet to nil in your lsp-mode settings
;;   to avoid odd behavior with snippets and indentation
(use-package yasnippet
  :ensure t)

;; Use the Debug Adapter Protocol for running tests and debugging
(use-package posframe
  ;; Posframe is a pop-up tool that must be manually installed for dap-mode
  :ensure t)

(use-package dap-mode
  :ensure t
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode)
)

;; TREEMACS
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay        0.5
          treemacs-directory-name-transformer      #'identity
          treemacs-display-in-side-window          t
          treemacs-eldoc-display                   t
          treemacs-file-event-delay                5000
          treemacs-file-extension-regex            treemacs-last-period-regex-value
          treemacs-file-follow-delay               0.2
          treemacs-file-name-transformer           #'identity
          treemacs-follow-after-init               t
          treemacs-expand-after-init               t
          treemacs-git-command-pipe                ""
          treemacs-goto-tag-strategy               'refetch-index
          treemacs-indentation                     2
          treemacs-indentation-string              " "
          treemacs-is-never-other-window           nil
          treemacs-max-git-entries                 5000
          treemacs-missing-project-action          'ask
          treemacs-move-forward-on-expand          nil
          treemacs-no-png-images                   nil
          treemacs-no-delete-other-windows         t
          treemacs-project-follow-cleanup          nil
          treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                        'left
          treemacs-read-string-input               'from-child-frame
          treemacs-recenter-distance               0.1
          treemacs-recenter-after-file-follow      nil
          treemacs-recenter-after-tag-follow       nil
          treemacs-recenter-after-project-jump     'always
          treemacs-recenter-after-project-expand   'on-distance
          treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
          treemacs-show-cursor                     nil
          treemacs-show-hidden-files               t
          treemacs-silent-filewatch                nil
          treemacs-silent-refresh                  nil
          treemacs-sorting                         'alphabetic-asc
          treemacs-select-when-already-in-treemacs 'move-back
          treemacs-space-between-root-nodes        t
          treemacs-tag-follow-cleanup              t
          treemacs-tag-follow-delay                1.5
          treemacs-text-scale                      nil
          treemacs-user-mode-line-format           nil
          treemacs-user-header-line-format         nil
          treemacs-width                           35
          treemacs-width-is-initially-locked       t
          treemacs-workspace-switch-cleanup        nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)

    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple)))

    (treemacs-hide-gitignored-files-mode nil))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :ensure t
  :after (treemacs evil)
  :ensure t)

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)

;; ;; LANGUAGES
;; ;; Python
(use-package python
  :ensure t
  :mode ("\\.py\\'" . python-mode))

;; ;; Custom formatting of docstrings
;; (use-package python-docstring
;;   :ensure t
;;   :hook
;;   (python-mode . python-docstring-mode))

;; ;; Python virtual env management
;; (use-package pyvenv
;;   :ensure t
;;   :init
;;   (setenv "WORKON_HOME" "~/.pyenv/versions"))

;; Typescript
(use-package typescript-mode
  :ensure t
  :mode "\\.ts\\'")

;; Kotlin
(use-package kotlin-mode
  :ensure t
  :mode "\\.kt\\'")

;; Yaml
(use-package yaml-mode
    :ensure t
    :mode "\\.yaml\\'")

;; TOML
(use-package toml-mode
    :ensure t
    :mode "\\.toml\\'")

;; Gradle
(use-package gradle-mode
  :ensure t
  :mode "\\.gradle\\'")

;; Groovy
(use-package groovy-mode
  :ensure t
  :mode "\\.groovy\\'")

;; Nix
(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'")

;; MISC

;; Editorconfig for unified formatting standards
(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package auctex
  :ensure t
  :defer t)

;; FORMATTING
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
(setq-default typescript-indent-level 2)

;; Whitespaces
(require 'whitespace)
(setq whitespace-style '(face empty tabs lines-tail trailing))
(global-whitespace-mode t)

;; Enable nice rendering of diagnostics like compile errors.
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode))

;; Direnv for directory-local commands and such
;; (use-package direnv
;;   :ensure t
;;   :hook
;;   (before-hack-local-variables . #'direnv-update-environment)
;;   (prog-mode-hook . #'direnv--maybe-update-environment)
;;   :config
;;   (direnv-mode))
(use-package envrc
  :ensure t
  :config
  (envrc-global-mode))

;; Babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (R . t)
   (python . t)
   (latex . t)
   (calc . t)
   (java . t)
   (sql . t)))

(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.5))

(require 'generic-x)
(add-to-list 'auto-mode-alist '("\\..*ignore$" . hosts-generic-mode))

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
 '(custom-safe-themes
   '("2809bcb77ad21312897b541134981282dc455ccd7c14d74cc333b6e549b824f3" "0598c6a29e13e7112cfbc2f523e31927ab7dce56ebb2016b567e1eff6dc1fd4f" default))
 '(package-selected-packages
   '(gnu-apl-mode lsp-ui lsp-mode editorconfig babel ob-ipython sqlformat terraform-mode python-docstring evil-mc evil-visual-mark-mode typescript-mode pyenv-mode toml-mode ejc-sql solarized-theme use-package elpy yaml-mode web-mode smart-tabs-mode scss-mode sass-mode python-mode projectile php-mode pallet neotree markdown-mode lua-mode jdee helm haskell-mode groovy-mode gradle-mode go-mode gitignore-mode flappymacs ess-R-data-view ensime dockerfile-mode coffee-mode auctex)))
