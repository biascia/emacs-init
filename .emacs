;; add melpa to package archives, as vterm is on melpa:
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(require 'use-package)
(setq use-package-always-ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; theme

(use-package spacemacs-theme
  :vc (:url "https://github.com/nashamri/spacemacs-theme" :rev :newest)
  :config
  (load-theme 'spacemacs-dark t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; base packages

(use-package treemacs :ensure t)

(use-package corfu
  :custom
  (corfu-auto t)          ;; Enable automatic popup
  (corfu-quit-no-match t) ;; Hide popup when no match is found
  :init
  (global-corfu-mode))

;; markdown
;; requires `brew install pandoc`
(use-package markdown-mode
  :ensure t
  :custom
  (markdown-command "pandoc"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; global keys
(global-set-key (kbd "<f5>") 'revert-buffer)
(global-set-key (kbd "<f6>") 'recompile)
(global-set-key (kbd "<f7>") 'compile)
(global-set-key (kbd "<f8>") 'vterm-other-window)
(global-set-key (kbd "<f9>") 'comment-region)
(global-set-key (kbd "<f10>") 'uncomment-region)
(global-set-key (kbd "<f12>") 'claude-code)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; inhibit startup screen
(setq inhibit-startup-screen t)
(add-hook 'emacs-startup-hook 'delete-other-windows)
(setq initial-scratch-message nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; zoom in and zoom out
(global-set-key [C-mouse-4] 'text-scale-increase)
(global-set-key [C-mouse-5] 'text-scale-decrease)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mouse drag copy
(setq mouse-drag-copy-region t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; upper and lower cases
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; make URLs clickable

(add-hook 'text-mode-hook 'goto-address-mode)
(add-hook 'prog-mode-hook 'goto-address-mode)
(add-hook 'vterm-mode-hook 'goto-address-mode)

;; use windows browser to open URLs when on WSL
;; requires sudo apt install wslu
(setq browse-url-browser-function 'browse-url-default-browser)
(setq browse-url-browser-function
      (lambda (url &optional _new-window)
        (start-process "browser" nil "wslview" url)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; python

;; pet detects the per-project Python interpreter (conda, venv, poetry, etc.)
;; and lets eglot use the matching pylsp instead of the base-env one.
;; Each project env needs: pip install "python-lsp-server[all]"
(use-package yaml :ensure t)

(use-package pet
  :ensure t
  :config
  (pet-eglot-setup)
  (add-hook 'python-mode-hook 'eglot-ensure))

;; install black on base env and make it available through an alias
;; e.g. `alias black='conda run -n base -- black'`
(use-package blacken
  :ensure t
  :custom
  (blacken-line-length 100)
  (blacken-target-version "py313"))

(use-package python-pytest
  :ensure t
  :bind (:map python-mode-map
              ("C-c t t" . python-pytest-dispatch)
              ("C-c t f" . python-pytest-file)
              ("C-c t p" . python-pytest-function-at-point)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; claude code

;; install required inheritenv dependency:
(use-package inheritenv
  :vc (:url "https://github.com/purcell/inheritenv" :rev :newest))

;; for eat terminal backend:
(use-package eat :ensure t)

;; for vterm terminal backend:
(use-package vterm :ensure t)

;; monet
(use-package monet
  :vc (:url "https://github.com/stevemolitor/monet" :rev :newest))

;; install claude-code.el
(use-package claude-code :ensure t
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)
  :config
  ;; optional IDE integration with Monet
  (add-hook 'claude-code-process-environment-functions #'monet-start-server-function)
  (monet-mode 1)

  (claude-code-mode)
  :bind-keymap ("C-c c" . claude-code-command-map)

  ;; Optionally define a repeat map so that "M" will cycle thru Claude auto-accept/plan/confirm modes after invoking claude-code-cycle-mode / C-c M.
  :bind
  (:repeat-map my-claude-code-map ("M" . claude-code-cycle-mode)))

;; prevent monet diff buffer from stealing focus
(defun my/monet-display-diff-no-select (orig-fun &rest args)
  "Advice to display diff buffer without selecting its window."
  (save-selected-window
    (apply orig-fun args)))
(with-eval-after-load 'monet
  (advice-add 'monet-simple-diff-tool :around #'my/monet-display-diff-no-select))

(setq claude-code-terminal-backend 'vterm)
(setq claude-code-toggle-auto-select t)
;; open claude code terminal on the right
(setq claude-code-display-window-fn
      (lambda (buffer)
        (let ((window (display-buffer buffer '((display-buffer-in-side-window)
                                               (side . right)
                                               (window-width . 0.5)))))
          (select-window window))))
