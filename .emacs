(require 'package)
(add-to-list 'package-archives
             '("gnu" . "https://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; global settings

(setq compile-command "make ")
(global-set-key (kbd "<f5>") 'revert-buffer)
(global-set-key (kbd "<f6>") 'kill-buffer)
(global-set-key (kbd "<f7>") 'compile)
(global-set-key (kbd "<f8>") 'recompile)
(global-set-key (kbd "<f9>") 'comment-region)
(global-set-key (kbd "<f10>") 'uncomment-region)
(global-set-key (kbd "<f12>") 'python-pytest-dispatch)

(add-hook 'after-init-hook 'global-company-mode)

(require 'ansi-color)
(defun endless/colorize-compilation ()
  "Colorize from `compilation-filter-start' to `point'."
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region
     compilation-filter-start (point))))

(add-hook 'compilation-filter-hook
          #'endless/colorize-compilation)

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
;; c++

(setq c-default-style "k&r")
(setq indent-tabs-mode "nil")
(setq-default indent-tabs-mode nil)
(setq c-basic-offset 4)
(c-set-offset 'substatement-open '0)
(c-set-offset 'inline-open '0)

(add-hook 'find-file-hook 'auto-insert)
(setq auto-insert-alist
      '(("\\.hpp\\'"
	 nil
	 '(setq v2 (upcase (concat
			    (file-name-nondirectory
			     (file-name-sans-extension buffer-file-name))
			    "_" (file-name-extension buffer-file-name) "__" )))
	 "// Copyright © " (format-time-string "%Y") n
	 "#ifndef " v2 n
	 "#define " v2 n n
	 "class " (file-name-nondirectory (file-name-sans-extension buffer-file-name)) " {"
	 n _ n
	 "};" n n
	 "#endif" n
	 (indent-region (point-min) (point-max) nil)
	 )))

(setq auto-mode-alist (append '(("\\.cu$" . c++-mode)) auto-mode-alist))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gdb
(setq gdb-many-windows t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; latex
(add-hook 'reftex-load-hook 'imenu-add-menubar-index)
(add-hook 'reftex-mode-hook 'imenu-add-menubar-index)
(setq LaTeX-command "latex")
(setq TeX-PDF-mode t)
(add-hook 'LaTeX-mode-hook 'turn-on-flyspell)
(setq TeX-view-program-list (quote (("evince" ("") ""))))
(setq doc-view-continuous t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sh
(add-hook 'sh-mode-hook
	  (lambda ()
	    (set (make-local-variable 'compile-command)
		 (format "bash %s " (file-name-nondirectory buffer-file-name)))
	    )
	  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; js
(setq js-indent-level 2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; python
(package-initialize)
(elpy-enable)
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt")
;; (setenv "WORKON_HOME" "/home/tommaso/miniconda3/envs")
;; (pyvenv-mode 1)
;; (pyvenv-workon "ludovico")
(setq elpy-rpc-timeout 10)
(setq elpy-rpc-virtualenv-path 'current)
(setq elpy-rpc-backend "jedi")

(add-to-list 'auto-insert-alist '("\\.py\\'" . skeletons/copyright-py))
(define-skeleton skeletons/copyright-py
  "copyright statement python files"
  nil
  "# Copyright (C) " (format-time-string "%Y") n n n
  )

(add-hook 'python-mode-hook 
          (lambda ()
            (set (make-local-variable 'compile-command)
                 (format "python %s " (file-name-nondirectory buffer-file-name)))))

(require 'ein)
(setq ein:output-area-inlined-images t)
(setq ein:use-auto-complete t)
(setq ein:use-smartrep t)
(setq ein:cell-traceback-level 10)

(setq blacken-line-length 100)
(setq blacken-skip-string-normalization t)
(setq python-pytest-arguments (quote ("--color" "--capture=no" "--verbose")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom variables
(custom-set-variables
 '(ansi-color-names-vector
   ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
 '(auth-source-save-behavior nil)
 '(custom-enabled-themes '(spacemacs-dark))
 '(custom-safe-themes
   '("bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" default))
 '(package-selected-packages
   '(conda python-pytest ein sphinx-doc spacemacs-theme py-isort pdf-tools list-packages-ext flymake-python-pyflakes elpy blacken auctex))
 '(quote
   (ansi-color-faces-vector
    [default default default italic underline success warning error])))
