;;; vs2008-theme.el --- Visual Studio 2008 default light color scheme -*- lexical-binding: t; -*-

;; Author: generated for Chad
;; Keywords: faces, theme
;; Version: 1.0

;;; Commentary:
;;
;; A faithful port of the default Microsoft Visual Studio 2008 text-editor
;; color scheme.  Palette derived directly from VS screenshots:
;;
;;   plain text   #000000 on #FFFFFF
;;   keyword      #0000FF   (blue)
;;   comment      #008000   (green)
;;   doc comment  #808080   (gray, /// XML doc)
;;   string       #A31515   (maroon)
;;   user type    #2B91AF   (teal)
;;   number       #000000   (VS 2008 does not color numbers by default)
;;   XML/HTML tag #A31515   (maroon)
;;   XML attr     #FF0000   (red)
;;   XML attr val #0000FF   (blue)
;;   tag/<>/=     #0000FF   (blue)
;;   line numbers #2B91AF   (teal)
;;   selection    #3399FF   (blue)
;;
;; Install: drop this file in a directory on `custom-theme-load-path' and
;;   (load-theme 'vs2008 t)

;;; Code:

(deftheme vs2008
  "Default Visual Studio 2008 light editor color scheme.")

(let ((class '((class color) (min-colors 89)))
      ;; --- core palette ---
      (bg            "#FFFFFF")
      (fg            "#000000")
      (keyword       "#0000FF")
      (comment       "#008000")
      (doc           "#808080")
      (string        "#A31515")
      (type          "#2B91AF")
      (number        "#000000")
      (preproc       "#0000FF")
      ;; --- xml / html ---
      (xml-tag       "#A31515")
      (xml-attr      "#FF0000")
      (xml-val       "#0000FF")
      (xml-delim     "#0000FF")
      ;; --- ui chrome (2008-era, not the 2012 #007ACC bar) ---
      (linenum       "#2B91AF")
      (gutter-bg     "#FFFFFF")
      (region        "#3399FF")
      (region-fg     "#FFFFFF")
      (hl            "#F5F5F5")
      (paren         "#BADFFF")
      (ml-bg         "#C9D5E8")
      (ml-fg         "#0A0A0A")
      (ml-inact-bg   "#EEF1F7")
      (ml-inact-fg   "#5A5A5A")
      (border        "#9EB6CE")
      (warning       "#FF0000")
      (lazy          "#FFFFAA"))

  (custom-theme-set-faces
   'vs2008

   ;; --- base ---
   `(default        ((,class (:background ,bg :foreground ,fg))))
   `(cursor         ((,class (:background ,fg))))
   `(region         ((,class (:background ,region :foreground ,region-fg))))
   `(highlight      ((,class (:background ,paren))))
   `(hl-line        ((,class (:background ,hl))))
   `(fringe         ((,class (:background ,bg :foreground ,fg))))
   `(vertical-border ((,class (:foreground ,border))))
   `(minibuffer-prompt ((,class (:foreground ,keyword :weight bold))))
   `(shadow         ((,class (:foreground ,doc))))

   ;; --- font-lock (syntax) ---
   `(font-lock-keyword-face            ((,class (:foreground ,keyword))))
   `(font-lock-builtin-face            ((,class (:foreground ,keyword))))
   `(font-lock-constant-face           ((,class (:foreground ,keyword)))) ; true/false/null
   `(font-lock-preprocessor-face       ((,class (:foreground ,preproc))))
   `(font-lock-comment-face            ((,class (:foreground ,comment))))
   `(font-lock-comment-delimiter-face  ((,class (:foreground ,comment))))
   `(font-lock-doc-face                ((,class (:foreground ,doc))))
   `(font-lock-doc-markup-face         ((,class (:foreground ,doc))))
   `(font-lock-string-face             ((,class (:foreground ,string))))
   `(font-lock-type-face               ((,class (:foreground ,type))))
   `(font-lock-function-name-face      ((,class (:foreground ,fg))))
   `(font-lock-variable-name-face      ((,class (:foreground ,fg))))
   `(font-lock-property-name-face      ((,class (:foreground ,fg))))
   `(font-lock-property-use-face       ((,class (:foreground ,fg))))
   `(font-lock-number-face             ((,class (:foreground ,number))))
   `(font-lock-negation-char-face      ((,class (:foreground ,fg))))
   `(font-lock-warning-face            ((,class (:foreground ,warning :weight bold))))

   ;; --- line numbers ---
   `(line-number              ((,class (:background ,gutter-bg :foreground ,linenum))))
   `(line-number-current-line ((,class (:background ,gutter-bg :foreground ,linenum :weight bold))))
   `(linum                    ((,class (:background ,gutter-bg :foreground ,linenum))))

   ;; --- search / parens ---
   `(isearch        ((,class (:background ,region :foreground ,region-fg))))
   `(lazy-highlight  ((,class (:background ,lazy :foreground ,fg))))
   `(show-paren-match ((,class (:background ,paren :weight bold))))
   `(show-paren-mismatch ((,class (:background ,warning :foreground ,bg :weight bold))))

   ;; --- mode line (VS 2008 gray-blue chrome) ---
   `(mode-line          ((,class (:background ,ml-bg :foreground ,ml-fg :box (:line-width 1 :color ,border)))))
   `(mode-line-inactive ((,class (:background ,ml-inact-bg :foreground ,ml-inact-fg :box (:line-width 1 :color ,border)))))
   `(mode-line-buffer-id ((,class (:weight bold))))

   ;; --- nXML ---
   `(nxml-element-local-name        ((,class (:foreground ,xml-tag))))
   `(nxml-tag-delimiter             ((,class (:foreground ,xml-delim))))
   `(nxml-tag-slash                 ((,class (:foreground ,xml-delim))))
   `(nxml-attribute-local-name      ((,class (:foreground ,xml-attr))))
   `(nxml-attribute-value           ((,class (:foreground ,xml-val))))
   `(nxml-attribute-value-delimiter ((,class (:foreground ,xml-val))))
   `(nxml-namespace-attribute-xmlns ((,class (:foreground ,xml-attr))))
   `(nxml-comment-content-face      ((,class (:foreground ,comment))))

   ;; --- SGML / html-mode ---
   `(sgml-namespace ((,class (:foreground ,xml-tag))))

   ;; --- web-mode ---
   `(web-mode-html-tag-face         ((,class (:foreground ,xml-tag))))
   `(web-mode-html-tag-bracket-face ((,class (:foreground ,xml-delim))))
   `(web-mode-html-attr-name-face   ((,class (:foreground ,xml-attr))))
   `(web-mode-html-attr-value-face  ((,class (:foreground ,xml-val))))
   `(web-mode-comment-face          ((,class (:foreground ,comment))))
   `(web-mode-string-face           ((,class (:foreground ,string))))
   `(web-mode-keyword-face          ((,class (:foreground ,keyword))))
   `(web-mode-type-face             ((,class (:foreground ,type))))

   ;; --- completion popup (subtle, period-appropriate) ---
   `(completions-common-part ((,class (:foreground ,keyword))))
   `(tooltip ((,class (:background "#FFFFE1" :foreground ,fg))))

   ;; --- diff ---
   `(diff-added ((,class (:foreground ,comment :background "#E6FFE6"))))
   `(diff-removed ((,class (:foreground ,warning :background "#FFE6E6"))))
   `(diff-changed ((,class (:foreground "#B8860B" :background "#FFE6CC"))))

   ;; --- org mode ---
   `(org-level-1 ((,class (:foreground ,keyword :weight bold :height 1.3))))
   `(org-level-2 ((,class (:foreground ,type :weight bold :height 1.2))))
   `(org-level-3 ((,class (:foreground ,comment :weight bold :height 1.1))))
   `(org-level-4 ((,class (:foreground ,string :weight bold))))
   `(org-code ((,class (:foreground ,string :background ,hl))))
   `(org-block ((,class (:background ,hl))))
   `(org-block-begin-line ((,class (:foreground ,comment :background ,hl))))
   `(org-block-end-line ((,class (:foreground ,comment :background ,hl))))

   ;; --- magit ---
   `(magit-diff-added ((,class (:foreground ,comment :background "#E6FFE6"))))
   `(magit-diff-removed ((,class (:foreground ,warning :background "#FFE6E6"))))
   `(magit-diff-context ((,class (:foreground ,fg))))
   `(magit-section-heading ((,class (:foreground ,keyword :weight bold))))
   `(magit-branch-local ((,class (:foreground ,type :weight bold))))
   `(magit-branch-remote ((,class (:foreground ,comment :weight bold))))

   ;; --- error/warning/success ---
   `(error   ((,class (:foreground ,warning :weight bold))))
   `(warning ((,class (:foreground "#B8860B" :weight bold))))
   `(success ((,class (:foreground ,comment :weight bold))))

   ;; --- flycheck/flymake ---
   `(flycheck-error ((,class (:underline (:style wave :color ,warning)))))
   `(flycheck-warning ((,class (:underline (:style wave :color "#B8860B")))))
   `(flycheck-info ((,class (:underline (:style wave :color ,type)))))

   ;; --- whitespace mode ---
   `(whitespace-trailing ((,class (:background "#FFE6E6"))))
   `(whitespace-tab ((,class (:foreground "#C0C0C0"))))
   `(whitespace-space ((,class (:foreground "#D0D0D0"))))

   ;; --- misc ---
   `(link    ((,class (:foreground ,keyword :underline t))))

   ;; --- eat terminal colors (ANSI colors for light background) ---
   `(eat-term-font-0 ((,class (:background ,bg))))
   `(eat-term-bold ((,class (:weight bold))))

   ;; Normal colors (0-7)
   `(eat-term-color-0 ((,class (:foreground "#000000" :background "#000000"))))   ; black
   `(eat-term-color-1 ((,class (:foreground "#CD3131" :background "#CD3131"))))   ; red
   `(eat-term-color-2 ((,class (:foreground "#00AA00" :background "#00AA00"))))   ; green
   `(eat-term-color-3 ((,class (:foreground "#AA5500" :background "#AA5500"))))   ; yellow/brown
   `(eat-term-color-4 ((,class (:foreground "#0451A5" :background "#0451A5"))))   ; blue
   `(eat-term-color-5 ((,class (:foreground "#BC05BC" :background "#BC05BC"))))   ; magenta
   `(eat-term-color-6 ((,class (:foreground "#0598BC" :background "#0598BC"))))   ; cyan
   `(eat-term-color-7 ((,class (:foreground "#555555" :background "#555555"))))   ; white (dark gray)

   ;; Bright colors (8-15)
   `(eat-term-color-8 ((,class (:foreground "#666666" :background "#666666"))))   ; bright black (gray)
   `(eat-term-color-9 ((,class (:foreground "#E50000" :background "#E50000"))))   ; bright red
   `(eat-term-color-10 ((,class (:foreground "#00DD00" :background "#00DD00")))) ; bright green
   `(eat-term-color-11 ((,class (:foreground "#DDDD00" :background "#DDDD00")))) ; bright yellow
   `(eat-term-color-12 ((,class (:foreground "#0066FF" :background "#0066FF")))) ; bright blue
   `(eat-term-color-13 ((,class (:foreground "#DD00DD" :background "#DD00DD")))) ; bright magenta
   `(eat-term-color-14 ((,class (:foreground "#00DDDD" :background "#00DDDD")))) ; bright cyan
   `(eat-term-color-15 ((,class (:foreground "#000000" :background "#000000")))) ; bright white (black)
   )

  (custom-theme-set-variables
   'vs2008
   `(frame-background-mode 'light)))

;; Ensure cursor color is applied at the frame level, since
;; custom-theme-set-faces for 'cursor doesn't always override
;; the frame parameter left by previously loaded themes.
(defun vs2008--set-cursor-color (&optional _theme)
  "Set cursor color when vs2008 theme is active."
  (when (member 'vs2008 custom-enabled-themes)
    (set-cursor-color "#000000")))

(add-hook 'after-init-hook #'vs2008--set-cursor-color)
(add-hook 'enable-theme-functions #'vs2008--set-cursor-color)

;;;###autoload
(when (and (boundp 'custom-theme-load-path) load-file-name)
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'vs2008)
(provide 'vs2008-theme)
;;; vs2008-theme.el ends here
