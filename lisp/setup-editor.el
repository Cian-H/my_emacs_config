;;; setup-editor.el --- Text editor configurations -*- lexical-binding: t; -*-

;; Set basic indentation settings (4 spaces, no tabs)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default c-basic-offset 4)
(setq-default js-indent-level 4)

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

;; --- Keybindings setup ---
(with-eval-after-load 'general
  ;; Todo jump bindings (normal mode)
  (general-define-key
   :states 'normal
   "]t" 'hl-todo-next
   "[t" 'hl-todo-previous)

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
