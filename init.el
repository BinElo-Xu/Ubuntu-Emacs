;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :custom
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results t)
  :config
  (auto-package-update-maybe)
  (auto-package-update-at-time "09:00"))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package general
  :after evil
  :config
  (general-create-definer rune/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (rune/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme")
    "b" '(counsel-switch-buffer :which-key "switch buffer")))

(use-package evil
  :demand t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)
  (evil-set-initial-state 'org-agenda-mode 'motion)
  (evil-set-initial-state ' calendar-mode 'motion))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

  ;; You will most likely need to adjust this font size for your system!
  (defvar runemacs/default-font-size 180)

  (setq inhibit-startup-message t)

  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (tooltip-mode -1)
  (menu-bar-mode -1)
  (set-fringe-mode 10)

  (setq visible-bell t)

  (column-number-mode)
  (global-display-line-numbers-mode t)

  (dolist (mode '(org-mode-hook
		  term-mode-hook
		  treemacs-mode-hook
		  eshell-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0))))


  (load-theme 'wombat t)

(set-face-attribute 'default nil :font "Fira Code Retina" :height runemacs/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 180)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height 195 :weight 'regular)

;; Set the chinese fronts
(set-fontset-font t 'han (font-spec :family "LXGW WenKai") nil 'prepend)

(defun efs/auto-harden-visual-wrap-behind-point ()
  "After a command, check if a visual line break occurred just before
the current line and, if so, make it a hard newline.
This is designed to be a fast, lightweight function for `post-command-hook`."
  ;; This `when` is a fast check. If the mode isn't on, do nothing.
  (when visual-fill-column-mode
    ;; We operate without moving the user's point.
    (save-excursion
      ;; Move to the beginning of the current visual line, then up to the previous visual line.
      ;; This is where the soft wrap would have just been created by typing.
      (when (zerop (line-move-visual -1))
        ;; `line-move-visual` returns 0 on success.
        ;; Now, go to the end of *that* visual line (the one we just moved to).
        (end-of-visual-line)
        ;; If we are not at the end of the buffer and the character ahead
        ;; is not a newline, it means we found a soft wrap.
        (unless (or (eobp) (looking-at-p "\n"))
          ;; Insert a real newline to "harden" the wrap.
          (insert "\n"))))))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 110
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1)
  (add-hook 'post-command-hook #'efs/auto-harden-visual-wrap-behind-point nil t))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

(use-package ivy
  :demand t
  :diminish ivy-mode
  :bind (("C-s" . swiper)
         ("M-x" . counsel-M-x)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)	
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

;; M-x all-the-icons-install-fonts

(use-package all-the-icons)

(use-package counsel
  :after ivy
  :bind (("C-x C-f" . counsel-find-file)))

;; Doom Modeline
(use-package doom-modeline
  :demand t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package doom-themes
  :demand t)

(use-package which-key
  :demand t
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 0.3))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package hydra
  :ensure t
  :defer t)

(use-package use-package-hydra
  :ensure t
  :after hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(rune/leader-keys
 "ts" '(hydra-text-scale/body :which-key "scale text"))

(defun efs/org-font-setup ()
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(use-package org
  :defer t ;; Defer loading until org-mode is actually used
  :bind (("C-c a" . org-agenda)
	     ("C-c c" . org-capture))
  :config
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  ;; Set UI 
  (setq org-ellipsis " ▾")
  ;; 让 Startup 中 DONE 的条目也折叠起来
  (setq org-startup-folded 'content)
  ;; 改进 org-indent-mode 的视觉效果
  (setq org-src-preserve-indentation t)
  (setq org-pretty-entities t)
  (setq org-hide-emphasis-markers t)

  ;; Set org-agenda
  (setq org-agenda-files '("~/Projects/Org/agenda/Habit.org"
                           "~/Projects/Org/agenda/Inbox.org"
			   ))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
	'((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")))

  (setq org-refile-targets
	'(("Archive.org" :maxlevel . 1)
	  ))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)
  ;; Set capture-templates
  (setq org-capture-templates
	`(("i" "Ideas" entry (file+olp"~/Projects/Org/agenda/Inbox.org" "Idea")
	   "** %?\n \n %a")
	  ("t" "Todo" entry (file+olp"~/Projects/Org/agenda/Inbox.org" "Todo")
	   "** TODO %?\n \n %a")
	  ))


  ;; 调用字体设置
  (efs/org-font-setup))

(use-package org-modern
  :ensure t
  :after org
  :config
  ;; --- 自定义 org-modern 的外观 ---
  ;; 这是美化列表的核心！你可以从 'unicode, 'fancy, 'default 中选择
  (setq org-modern-list-bulleteer-styles
        '((?* . "•")
          (?+ . "–")
          (?- . "·")))
  
  ;; 美化 checklist 方框
  ;; 你可以换成其他喜欢的 Unicode 字符，比如 ("✔" "☐" "–")
  (setq org-modern-checkbox-character '("✓" "☐" "—"))

  ;; 美化标题
  (setq org-modern-headline-bullets
        '((:default . "›")
          (1 . "◉")
          (2 . "○")
          (3 . "●"))))

;; 强制在Org Mode的Normal State下将TAB绑定到org-cycle
(evil-define-key 'normal org-mode-map (kbd "TAB") 'org-cycle)
;; --- 最终的 Org Mode 钩子 ---
;; 这个函数会在每次打开 .org 文件时运行
(defun my-final-org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1) ; 自动换行
  (org-modern-mode 1))  ; 确保 org-modern 最后启用

(add-hook 'org-mode-hook #'my-final-org-mode-setup)

;; mixed-pitch 是 variable-pitch-mode 的好搭档，确保它已安装
(use-package mixed-pitch
  :ensure t
  :hook (org-mode . mixed-pitch-mode))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)))

;; This is needed for as of org 9.7
(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

;; Automatically tangle our Emacs.org config file when we save it
(defun efs/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/.emacs.d/Emacs.org"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(use-package org-roam
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/Projects/Org")
  (org-roam-completion-everywhere t)
    :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         :map org-mode-map
         ("C-M-i"    . completion-at-point)
         :map org-roam-dailies-map
         ("Y" . org-roam-dailies-capture-yesterday)
         ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies) ;; Ensure the keymap is available
  (org-roam-db-autosync-mode))
(setq org-roam-dailies-directory "~/Projects/Org/journal")

(setq org-roam-capture-templates
   '(("d" "default" plain
     "%?"
     :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
     :unnarrowed t)
     ("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
     :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: Project")
     :unnarrowed t)))

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy)

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package flycheck
  :ensure t
  :config
  (setq truncate-lines nil) ; 如果单行信息很长会自动换行
  :hook
  (prog-mode . flycheck-mode))

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp-deferred))))

(use-package pyvenv
  :demand t
  :after python
  :config
  (setenv "WORKON_HOME" (expand-file-name "~/miniconda3/envs"))
  (pyvenv-mode 1))

(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "--simple-prompt -i")

(use-package magit
  :defer t
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single
  :ensure nil
  :load-path "~/.emacs.d/lisp/")

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package eterm-256color
  :hook (term-mode . eterm-256color-mode))

(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))

(defun efs/configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  ;; Bind some useful keys for evil-mode
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "C-r") 'counsel-esh-history)
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt)

(use-package eshell
  :hook (eshell-first-time-mode . efs/configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'powerline))

(use-package tex
  :ensure auctex
  :defer t
  :config
  ;; 默认使用 pdfLaTeX 进行编译
  (setq-default TeX-master nil)
  ;; 开启 PDF 预览模式
  (setq TeX-PDF-mode t)
  ;; 设置默认的 PDF 查看器 (Evince 是 Ubuntu 的默认查看器)
  (setq TeX-view-program-selection '((output-pdf "Evince")))
  ;; 启用对中文的支持 (比如 CTeX, xeCJK 等)
  (setq TeX-engine 'xetex) ; 推荐使用 XeTeX 引擎处理 UTF-8 和中文字体
  (setq TeX-command-extra-options "-shell-escape")
  ;; 让 AUCTeX 自动解析我们的 .tex 文件以提供更好的补全
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  ;; 更好的字体显示
  (add-hook 'LaTeX-mode-hook (lambda ()
                              (setq-local TeX-electric-sub-and-superscript t)
                              ;; 使用更漂亮的符号显示数学公式等
                              (TeX-source-correlate-mode)
                              (TeX-fold-mode 1))))

(use-package lsp-latex
  :ensure t
  :after (tex lsp-mode)
  :hook (LaTeX-mode . lsp-deferred)) ; 当进入 LaTeX-mode 时，直接调用 lsp-deferred

(use-package company-auctex
  :ensure t
  :after (tex company)
  :config
  (company-auctex-init))
;; (可选但推荐) 将 company-auctex 添加到 company 后端
;; 这会让 company 优先使用 auctex 提供的补全建议
(with-eval-after-load 'company
  (add-to-list 'company-backends '(company-auctex :with company-yasnippet)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("bffa708323223011c750567c2d53a2070085188f63561a0f5a549d10b7593c17" default))
 '(package-selected-packages
   '(olivetti mixed-pitch org-superstar org-modern evil-magit magit counsel-projectile projectile hydra evil-collection evil general all-the-icons doom-themes helpful ivy-rich which-key doom-modeline counsel ivy)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
