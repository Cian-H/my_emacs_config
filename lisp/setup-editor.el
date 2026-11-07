;;; setup-editor.el --- Text editor configurations -*- lexical-binding: t; -*-

;; Set basic indentation settings (4 spaces, no tabs)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default c-basic-offset 4)
(setq-default js-indent-level 4)
(setq-default scroll-margin 4) ; Minimal number of screen lines to keep above/below cursor

;; Set custom file associations matching Neovim
(add-to-list 'auto-mode-alist '("\\.scl\\'" . prog-mode))
(add-to-list 'auto-mode-alist '("\\.pro\\(log\\)?\\'" . prolog-mode))
(add-to-list 'auto-mode-alist '("\\.nu\\'" . sh-mode))
(add-to-list 'auto-mode-alist '("\\.mojo\\'" . python-mode))
(add-to-list 'auto-mode-alist '("\\.pig\\'" . sql-mode))
(add-to-list 'auto-mode-alist '("\\.h\\(ql\\|ive\\)\\'" . sql-mode))

;; Shell configuration (nushell if installed)
(when (executable-find "nu")
  (setq shell-file-name (executable-find "nu")))

;; 2-space indentation hooks for languages matching ftplugin
(defun my/set-two-space-indent ()
  (setq-local tab-width 2)
  (setq-local standard-indent 2))

(add-hook 'lisp-mode-hook #'my/set-two-space-indent)
(add-hook 'scheme-mode-hook #'my/set-two-space-indent)
(add-hook 'emacs-lisp-mode-hook #'my/set-two-space-indent)
(add-hook 'nix-mode-hook #'my/set-two-space-indent)

;; Enable line numbers and relative numbers (kickstart / neovim default)
(setq-default display-line-numbers 'relative
              display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; Disable line wrapping (mirrors vim.opt.wrap = false)
(setq-default truncate-lines t)

;; Enable mouse support (mirrors vim.opt.mouse = "a")
(xterm-mouse-mode 1)

;; Clipboard sharing between Emacs and system
(setq select-enable-clipboard t)

;; Highlight matching parentheses
(show-paren-mode 1)

;; Install and load undo-tree (provides Vim-like undo/redo branches)
(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode 1)
  ;; Keep undo history saved across restarts
  (setq undo-tree-auto-save-history t)
  ;; Save undo history in a central folder to avoid workspace clutter
  (setq undo-tree-history-directory-alist `(("." . ,(expand-file-name "undo-history" user-emacs-directory)))))

;; Install rainbow-delimiters for pretty matching bracket colors
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;; Install hl-todo for highlighting TODO/FIX/FIXME comments
(use-package hl-todo
  :ensure t
  :hook (prog-mode . hl-todo-mode)
  :config
  (setq hl-todo-keyword-faces
        '(("TODO"   . "#ff9e64")
          ("FIX"    . "#f7768e")
          ("FIXME"  . "#f7768e"))))

;; Modern buffer-based file explorer (dirvish) which mirrors oil.nvim and neo-tree.nvim
(use-package dirvish
  :ensure t
  :config
  (dirvish-override-dired-mode)
  (setq dirvish-mode-line-format '(:left (path index) :right (size mode)))
  (setq dirvish-attributes '(nerd-icons file-size collapse git-msg))
  ;; Keybindings inside dirvish are evil-friendly by default with evil-collection
  )

;; --- Custom Harpoon Implementation ---
;; High-performance, zero-dependency, and persists across restarts using savehist
(defvar my/harpoon-list nil "List of files marked by Harpoon.")

;; Save the Harpoon list across Emacs restarts
(with-eval-after-load 'savehist
  (add-to-list 'savehist-additional-variables 'my/harpoon-list))

(defun my/harpoon-add-file ()
  "Add the current file to Harpoon."
  (interactive)
  (let ((file (buffer-file-name)))
    (if (not file)
        (message "Buffer is not visiting a file")
      (unless (member file my/harpoon-list)
        (setq my/harpoon-list (append my/harpoon-list (list file))))
      (message "Added %s to Harpoon" (file-name-nondirectory file)))))

(defun my/harpoon-clear ()
  "Clear all Harpoon marks."
  (interactive)
  (setq my/harpoon-list nil)
  (message "Harpoon cleared"))

(defun my/harpoon-select (index)
  "Select Harpoon file at 1-based INDEX."
  (let ((file (nth (1- index) my/harpoon-list)))
    (if file
        (find-file file)
      (message "No Harpoon file at slot %d" index))))

(defun my/harpoon-select-1 () (interactive) (my/harpoon-select 1))
(defun my/harpoon-select-2 () (interactive) (my/harpoon-select 2))
(defun my/harpoon-select-3 () (interactive) (my/harpoon-select 3))
(defun my/harpoon-select-4 () (interactive) (my/harpoon-select 4))

(defun my/harpoon-quick-menu ()
  "Open Harpoon quick menu using completing-read (compatible with Vertico)."
  (interactive)
  (if (null my/harpoon-list)
      (message "Harpoon is empty")
    (let* ((choices (mapcar (lambda (f) (cons (file-name-nondirectory f) f)) my/harpoon-list))
           (selected (completing-read "Harpoon: " (mapcar #'car choices) nil t)))
      (find-file (cdr (assoc selected choices))))))

;; --- Yank / Path helper functions ---
(defun my/yank-relative-path ()
  "Copy relative path of current file to clipboard."
  (interactive)
  (if-let* ((file (buffer-file-name)))
      (let ((rel (file-relative-name file (or (project-root (project-current)) default-directory))))
        (kill-new rel)
        (message "Yanked relative path: %s" rel))
    (message "Buffer is not visiting a file")))

(defun my/yank-path-with-line ()
  "Copy relative path and line number of current buffer to clipboard."
  (interactive)
  (if-let* ((file (buffer-file-name)))
      (let* ((rel (file-relative-name file (or (project-root (project-current)) default-directory)))
             (res (format "%s:%d" rel (line-number-at-pos))))
        (kill-new res)
        (message "Yanked path with line: %s" res))
    (message "Buffer is not visiting a file")))

(defun my/yank-absolute-path ()
  "Copy absolute path of current file to clipboard."
  (interactive)
  (if-let* ((file (buffer-file-name)))
      (progn
        (kill-new file)
        (message "Yanked absolute path: %s" file))
    (message "Buffer is not visiting a file")))

;; --- Keybindings setup ---
(with-eval-after-load 'general
  ;; Normal mode global navigation & undotree
  (general-define-key
   :states 'normal
   "U" 'undo-tree-visualize
   "]t" 'hl-todo-next
   "[t" 'hl-todo-previous
   "]q" 'flymake-goto-next-error
   "[q" 'flymake-goto-prev-error)

  (my-leader-def
   ;; Rainbow Delimiters toggle
   "(" 'rainbow-delimiters-mode

   ;; Harpoon Group (<leader>h)
   "ha" 'my/harpoon-add-file
   "hc" 'my/harpoon-clear
   "hq" 'my/harpoon-quick-menu

   ;; Tree Group (<leader>t)
   "tt" 'dirvish-side              ; Toggle sidebar file tree (Neo-Tree toggle)
   "te" 'dirvish                   ; Open buffer-based explorer (Oil.nvim edit)
   "ts" 'dirvish-side              ; Show sidebar tree
   "tc" 'dirvish-side              ; Close sidebar tree
   "tf" 'dirvish-side              ; Focus sidebar tree

   ;; Yank / Path Group (<leader>y)
   "y" '(:ignore t :which-key "Yank/Path")
   "yp" 'my/yank-relative-path
   "yl" 'my/yank-path-with-line
   "ya" 'my/yank-absolute-path

   ;; UI / Toggles Group (<leader>u)
   "u" '(:ignore t :which-key "UI/Toggles")
   "ui" 'eglot-inlay-hints-mode
   "ud" 'flymake-mode
   "uw" 'visual-line-mode
   "ul" 'display-line-numbers-mode
   "us" 'flyspell-mode
   )

  ;; Harpoon slots mapped to Alt-a/s/d/f in normal mode (matches Neovim settings)
  (general-define-key
   :keymaps 'override
   :states 'normal
   "M-a" 'my/harpoon-select-1
   "A-a" 'my/harpoon-select-1
   "M-s" 'my/harpoon-select-2
   "A-s" 'my/harpoon-select-2
   "M-d" 'my/harpoon-select-3
   "A-d" 'my/harpoon-select-3
   "M-f" 'my/harpoon-select-4
   "A-f" 'my/harpoon-select-4)
  )

(provide 'setup-editor)
