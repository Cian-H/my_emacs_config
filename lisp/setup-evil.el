;;; setup-evil.el --- Vim modal editing and keybindings -*- lexical-binding: t; -*-

;; Set up Evil Mode (Vim emulator)
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil) ; Required for evil-collection
  (setq evil-want-C-u-scroll t)    ; Ctrl-u scrolls up
  (setq evil-want-C-i-jump t)      ; Tab jumps forward in jump list
  (setq evil-undo-system 'undo-tree) ; We'll setup undo-tree in setup-editor
  :config
  (evil-mode 1))

;; Evil Collection sets up vim keybindings across various non-editing buffers (e.g. dired, help)
(use-package evil-collection
  :ensure t
  :after evil
  :config
  (evil-collection-init))

;; Helper function to swap current window with next window (mimicking <C-w>x)
(defun my/window-swap-next ()
  "Swap the current window with the next window."
  (interactive)
  (let ((next-win (next-window)))
    (if (eq next-win (selected-window))
        (message "No other window to swap with")
      (window-swap-states (selected-window) next-win))))

;; General.el for mapping keybindings cleanly, especially leader keybindings
(use-package general
  :ensure t
  :after evil
  :config
  (general-evil-setup t)

  ;; Create a leader definer for SPC
  (general-create-definer my-leader-def
			  :states '(normal insert visual emacs)
			  :keymaps 'override
			  :prefix "SPC"
			  :global-prefix "M-SPC")

  ;; Define group descriptions for which-key
  (my-leader-def
   "s" '(:ignore t :which-key "Search")
   "c" '(:ignore t :which-key "Code")
   "d" '(:ignore t :which-key "Diagnostics")
   "g" '(:ignore t :which-key "Git")
   "r" '(:ignore t :which-key "Rename")
   "w" '(:ignore t :which-key "Workspace")
   "t" '(:ignore t :which-key "Tree")
   "l" '(:ignore t :which-key "Git/Magit")
   "o" '(:ignore t :which-key "Overseer/Tasks")
   "h" '(:ignore t :which-key "Harpoon")
   "x" '(:ignore t :which-key "Trouble/Diagnostics"))

  ;; Window navigation and management keybindings using Alt (Meta) keys
  ;; Bind both M- (Meta/Alt in Emacs) and A- (explicit Alt) for maximum compatibility
  (general-define-key
   :keymaps 'override
   :states '(normal insert visual emacs)
   ;; Window Navigation
   "M-h" 'windmove-left
   "M-j" 'windmove-down
   "M-k" 'windmove-up
   "M-l" 'windmove-right
   "A-h" 'windmove-left
   "A-j" 'windmove-down
   "A-k" 'windmove-up
   "A-l" 'windmove-right

   ;; Window Splits / Close
   "M-n" 'split-window-below           ; Mirrors Vim <C-w>s (horizontal split)
   "A-n" 'split-window-below
   "M-;" 'my/window-swap-next          ; Swap current window with next
   "A-;" 'my/window-swap-next
   "M-q" 'delete-window                 ; Close current window
   "A-q" 'delete-window

   ;; Window Resizing
   "M-=" 'enlarge-window
   "A-=" 'enlarge-window
   "M--" 'shrink-window
   "A--" 'shrink-window
   "M-." 'enlarge-window-horizontally
   "A-." 'enlarge-window-horizontally
   "M-," 'shrink-window-horizontally
   "A-," 'shrink-window-horizontally
   
   ;; Clear highlight on Esc (like vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>'))
   "<escape>" (lambda ()
                (interactive)
                (lazy-highlight-cleanup)
                (keyboard-quit)))
  )

;; Which-key shows a popup panel listing available completions for partial key sequences
(use-package which-key
  :ensure t
  :init
  (setq which-key-idle-delay 0.3)
  :config
  (which-key-mode))

(provide 'setup-evil)
