;;; setup-git.el --- Git Integration -*- lexical-binding: t; -*-

;; Magit: The gold standard for Git clients inside an editor (lazygit equivalent)
(use-package magit
  :ensure t)

;; Diff-hl: Highlights uncommitted changes in the gutter/margin (gitsigns.nvim equivalent)
(use-package diff-hl
  :ensure t
  :config
  (global-diff-hl-mode 1)
  ;; Enable margin mode in terminal Emacs so gutter highlights show up in CLI
  (unless (display-graphic-p)
    (diff-hl-margin-mode 1))
  ;; Dynamically update gutter marks as you type
  (diff-hl-flydiff-mode 1))

;; Configure Git Keybindings using General.el
(with-eval-after-load 'general
  (my-leader-def
   ;; Git Hunk Group (<leader>g)
   "gs" 'diff-hl-stage-hunk         ; SPC g s: Stage current hunk
   "gr" 'diff-hl-revert-hunk        ; SPC g r: Revert current hunk
   "gb" 'magit-blame-addition       ; SPC g b: Git Blame line

   ;; Magit/Lazygit Group (<leader>l)
   "lg" 'magit-status               ; SPC l g: Open Magit Status (lazygit equivalent)
   "ll" 'magit-log-current          ; SPC l l: Open Git Log
   )

  ;; Hunk Navigation in Normal mode (matches Neovim ]c and [c)
  (general-define-key
   :states 'normal
   "]c" 'diff-hl-next-hunk           ; ]c: Next hunk
   "[c" 'diff-hl-previous-hunk)      ; [c: Previous hunk
  )

(provide 'setup-git)
