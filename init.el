;; Disable unnecessary UI elements
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(setq custom-file (make-temp-file "emacs-custom"))
(setq ring-bell-function 'ignore)

;; Basic settings
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)
(setq warning-minimum-level :error)
(setq-default truncate-lines t)

;; Enable line numbers
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Set default font (optional)
;;(set-face-attribute 'default nil :font "RobotoMono Nerd Font-11")

;; Backup and auto-save files settings
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))
(setq auto-save-file-name-transforms `((".*" "~/.emacs.d/auto-save-list/" t)))

;; Enable y/n answers instead of yes/no
(fset 'yes-or-no-p 'y-or-n-p)

;; Extra paths
(defun add-to-path (path)
  (let* ((expanded-path (expand-file-name path))
         (exec-path-form expanded-path)
         (env-path-form (if (eq system-type 'windows-nt)
                            (subst-char-in-string ?/ ?\\ expanded-path)
                          expanded-path))
         (path-separator (if (eq system-type 'windows-nt) ";" ":"))
         (current-path (getenv "PATH")))
    (unless (member exec-path-form exec-path)
      (setenv "PATH" (concat current-path path-separator env-path-form))
      (setq exec-path (append exec-path (list exec-path-form))))))

(add-to-path "~/.asdf/shims")
(add-to-path "~/.sdkman/candidates/java/current/bin")
(add-to-path "~/.sdkman/candidates/leiningen/current/bin")

;; Melpa
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Theme
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-molokai t))

(use-package nerd-icons
  :ensure t)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))

;; Which key
(use-package which-key
  :init (which-key-mode))

;; Company
(use-package company
  :ensure t
  :config
  (setq company-ide-delay 0)
  (setq company-minimum-prefix-length 1)
  (global-company-mode t))

;; Auto treesitter mode
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; eglot
(use-package eglot
  :custom
  (eglot-ignored-server-capabilities '(:inlayHintProvider)))

;; eldoc
(use-package eldoc
  :custom
  (eldoc-echo-area-use-multiline-p nil))

;; Rainbow delimiters mode
(use-package rainbow-delimiters
  :ensure t
  :hook ((emacs-lisp-mode lisp-mode clojure-mode) . rainbow-delimiters-mode))

;; Vertico
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package savehist
  :ensure t
  :init
  (savehist-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map ("M-A" . marginalia-cycle))
  :init (marginalia-mode))

;; Projectile
(use-package projectile
  :ensure t
  :init (projectile-mode 1)
  (setq projectile-completion-system 'default))

;; Paredit
(use-package paredit
  :ensure t
  :hook
  (emacs-lisp-mode . paredit-mode)
  (lisp-mode       . paredit-mode))

;; Smart parens (for everything that is not lisp)
(use-package smartparens
  :ensure t
  :hook (prog-mode . (lambda ()
		       (unless (or (eq major-mode 'emacs-lisp-mode)
				   (eq major-mode 'clojure-mode)
				   (eq major-mode 'lisp-mode))
			 (smartparens-mode))))
  :config
  (require 'smartparens-config))

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package consult
  :ensure t
  :hook (completion-list-mode . consult-preview-at-point-mode))

(use-package embark-consult
  :ensure t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; ================= Languages ================= ;;

(use-package clojure-mode
  :ensure t
  :hook
  (clojure-mode . eglot-ensure)
  (clojure-mode . paredit-mode)
  :config
  (setq clojure-indent-style         'align-arguments
        clojure-indent-keyword-style 'always-align
        clojure-enable-indent-specs   nil))

(setq cider-repl-display-help-banner nil)
(use-package cider
  :ensure t
  :hook (cider-repl-mode . paredit-mode))

(use-package elixir-mode
  :ensure t)

(use-package zig-mode
  :ensure t
  :hook (zig-mode . eglot-ensure))

(use-package slime
  :ensure t
  :config (setq inferior-lisp-program "sbcl")
  :hook   (slime-repl-mode . paredit-mode))
