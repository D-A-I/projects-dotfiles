;;; init.el --- Initialization file for Emacs
;;; Commentary: Emacs Startup File --- initialization for Emacs
;;; ＊flycheckで数点エラーが出ているが、取り急ぎ放っておく

(require 'package)

;;; MELPAを追加
;;; Code:
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
;; MELPA-stableを追加
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
;; Marmaladeを追加
(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
;; Orgを追加
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
;; 初期化
(package-initialize)

;;; 以下の関数は、いずれ自分で書き直す（必要最低限で）
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
	      (expand-file-name (concat user-emacs-directory path))))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のディレクトリとサブディレクトリをload-pathに追加
(add-to-load-path "elisp" "conf" "public_repos")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files nil)
 '(package-selected-packages
   (quote
    (org-preview-html company clj-refactor cider multi-term ac-emoji flycheck auto-complete quickrun ## rainbow-delimiters paredit lispxmp open-junk-file helm mozc))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

; 起動画面の非表示
(setq inhibit-startup-screen t)

; モードの設定
(line-number-mode t)                ; 行番号
(column-number-mode t)              ; 列番号
(size-indication-mode t)            ; ファイルサイズ
(global-linum-mode t)               ; 常に行番号を表示する
(setq show-paren-delay 0)
(show-paren-mode t)                 ; 対応する括弧を強調表示
(setq show-paren-style 'expression) ; expressionは括弧内を強調表示する
(which-function-mode t)             ; 関数の表示

;; cua-mode
(cua-mode t)
(setq cua-enable-cua-keys nil)
(define-key global-map (kbd "C-x SPC") 'cua-set-rectangle-mark)

;; flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)

; タブ関連
(setq-default indent-tabs-mode nil) ; インデントにタブを使用しないようにする

; キーバインド
;; C-mにnew-line-and-indentを割当て
(global-set-key (kbd "C-m") 'newline-and-indent)
;; C-tにウィンドウ切り替えを割当て
(define-key global-map (kbd "C-t") 'other-window)
;; C-jにIMEの切替えキーを割当て
(global-set-key (kbd "C-j") 'toggle-input-method)
;; C-hを<DEL>（バックスペース）に割り当て -> 2019/05/03 鬼軍曹.elを入れたため不要
;; (define-key key-translation-map (kbd "C-h") (kbd "<DEL>"))

; タイトルバー
(setq frame-title-format "%f")
; バックアップファイル（*.~）を作らない
(setq make-backup-files nil)
; 行番号の桁数設定
(setq linum-format "%4d ")

; mozc（packageの読込み後にしないとエラーになる）
(when (require 'mozc nil t)                   ; mozcの読込み
  (set-language-environment "Japanese")       ; 日本語環境
  (setq default-input-method "japanese-mozc") ; IMEをjapanese-mozcにする
  (prefer-coding-system 'utf-8)
  :)

; 最近使ったファイルを自動保存する
(require 'recentf)
(setq recentf-save-file "~/.recentf")	; 最近開いたファイルの保存先
(setq recentf-exclude '(".recentf"))	; .recentfに含めないファイル
(run-with-idle-timer 30 t 'recentf-save-list)
(recentf-mode t)

;; 鬼軍曹
(require 'drill-instructor)
(setq drill-instructor-global t)

; elispの拡張
;; *scratch*バッファを保存
(require 'open-junk-file)
(setq open-junk-file-format "~/junk/%y%m%d/%h%m.")
(global-set-key (kbd "C-x C-z") 'open-junk-file)
;; emacs-lisp-modeで C-c C-d を入力すると注釈
(require 'lispxmp)
(define-key emacs-lisp-mode-map (kbd "C-c C-d") 'lispxmp)
;; 閉じ括弧を対応付ける
(require 'paredit)
(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
;; 括弧に色付けする
(require 'rainbow-delimiters)
(add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)

;;; rainbow-delimitersの強調表示
(require 'cl-lib)
(require 'color)
(cl-loop
 for index from 1 to rainbow-delimiters-max-face-count
 do
 (let ((face (intern (format "rainbow-delimiters-depth-%d-face" index))))
   (cl-callf color-saturate-name (face-foreground face) 30)))

; org-mode
(setq org-directory "~/Dropbox/doc/02_private/")
(setq org-mobile-inbox-for-pull "~/Dropbox/doc/02_private/flagged.org")
(setq org-mobile-directory "~/Dropbox/アプリ/MobileOrg/")
(setq org-default-notes-file "notes.org")
(setq org-agenda-files (list "this-week.org" "supplement.org"))
;; emacsを閉じた時に、Dropboxと同期
(require 'org)
(add-hook 'after-init-hook 'org-mobile-pull)
(add-hook 'kill-emacs-hook 'org-mobile-push)

;; auto-complete
(when (require 'auto-complete-config nil t)
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (ac-config-default)
  (setq ac-use-menu-map t)
  (setq ac-ignore-case nil))

; helm
(require 'helm-config)
(helm-mode t)

;; C-hで前の文字削除
(define-key helm-map (kbd "C-h") 'delete-backward-char)
(define-key helm-find-files-map (kbd "C-h") 'delete-backward-char)

;; TABとC-zを入れ替える
(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ;; 後でコメントを書く..
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)
(define-key helm-map (kbd "C-z")  'helm-select-action)

;; helmのキーバインド
(global-set-key (kbd "C-c h") 'helm-mini)
(global-set-key (kbd "C-c x") 'helm-M-x)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
;;; helm-occur
(global-set-key (kbd "C-M-o") 'helm-occur)
(define-key isearch-mode-map (kbd "C-o") 'helm-occur-from-isearch)
(define-key helm-map (kbd "C-c C-a") 'all-from-helm-occur)

;;; emoji
(when (require 'ac-emoji nil t)
  (add-to-list 'ac-modes 'text-mode)
  (add-to-list 'ac-modes 'markdown-mode)
  (add-to-list 'ac-modes 'org-mode)
  (add-hook 'text-mode-hook 'ac-emoji-setup)
  (add-hook 'markdown-mode-hook 'ac-emoji-setup)
  (add-hook 'org-mode-hook 'ac-emoji-setup))

;;; multi-term
(when (require 'multi-term nil t)
  (setq multi-term-program "/usr/local/bin/fish"))

;; Clojure環境は、一旦"IntelliJ IDEA"にしておく
; Clojure
;(use-package clojure-mode)

(provide 'init)
;;; init.el ends here
