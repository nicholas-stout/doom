;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))

;; (setq doom-font (font-spec :family "Iosevka Extended" :size 15 :weight 'regular))

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

;; Load `chezmoi.el'
(use-package! chezmoi
  :demand t)

;; (setq doom-theme 'noctalia)
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; Make backgrounds slightly transparent
(add-to-list 'default-frame-alist '(alpha-background . 95))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Make Org log when `TODO' entries are completed
(setq org-log-done t)

;; Set the default scroll-margin to 0
(setq-default scroll-margin 0)

;; Set the local scroll margin to 10 unless the major mode is a special mode
(defun my/set-scroll-margin ()
  (when buffer-file-name
    (setq-local scroll-margin 10)))

(add-hook 'after-change-major-mode-hook #'my/set-scroll-margin)

(setq scroll-conservatively 101)

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Enable `evil-cleverparens-mode' in `lisp-mode'
(add-hook! '(lisp-mode-hook emacs-lisp-mode-hook) #'evil-cleverparens-mode)

(after! org
  ;; Always have `org-agenda-follow-mode' enabled when opening `org-agenda'
  (defun my/org-agenda-ensure-follow-mode ()
    (unless org-agenda-follow-mode
      (org-agenda-follow-mode)))

  (add-hook 'org-agenda-mode-hook #'my/org-agenda-ensure-follow-mode))

;; Disable `org-modern' prettifying tables
(after! org-modern
  (setq org-modern-table nil))

(after! yasnippet
  (setq yas-snippet-revival nil))

;; Fix `evil-org-beginning-of-line'
(after! evil-org
  (defun my/evil-org-beginning-of-line (orig-fn &rest args)
    "There's a bug in the original `evil-org-beginning-of-line' that doesn't
fully respect `evil-respect-visual-line-mode' when it's `nil'. This advice
ensures that `visual-line-mode' is disabled when `evil-org-beginning-of-line'
is called."
    (let ((visual-line-mode nil))
      (apply orig-fn args)))

  (advice-add #'evil-org-beginning-of-line :around
              #'my/evil-org-beginning-of-line))

(after! dired
  (setq find-file-visit-truename nil))

(+global-word-wrap-mode +1)

;; Disable `flycheck-mode' in `lisp-interaction-mode'
(after! flycheck
  (add-hook 'lisp-interaction-mode-hook
            (lambda () (flycheck-mode -1))))

(add-to-list 'display-buffer-alist
             '("\\*docker-"
               (display-buffer-below-selected)
               (window-height . 0.4)))

;; Advise `eval-buffer' to print a message when successful
(advice-add #'eval-buffer :after
            (lambda (&rest _)
              (when (eq this-command 'eval-buffer)
                (message "Buffer evaluated."))))

;; Add keybind to open file in other frame
(map! :desc "Find file in a new frame"
      :leader "," #'find-file-other-frame)

(map! :after evil
      :nv "]j" #'evil-next-visual-line
      :nv "[j" #'evil-next-visual-line
      :nv "]k" #'evil-previous-visual-line
      :nv "[k" #'evil-previous-visual-line)

(map! :after flyspell
      :map flyspell-mode-map
      :ni "C-;" #'flyspell-correct-previous
      :n "zg" #'flyspell-correct-previous)

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(add-hook 'prog-mode-hook #'colorful-mode)

(custom-set-faces!
  '(line-number :foreground "#696969")
  '(org-list-dt :weight semibold)
  '(org-verbatim :weight semibold))

;; Enable `word-wrap-mode' when viewing Docker containers
(after! docker
  (add-hook 'docker-container-mode-hook #'+word-wrap-mode))

(show-smartparens-global-mode 1)
