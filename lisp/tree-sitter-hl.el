;;; tree-sitter-hl.el --- Syntax highlighting based on tree-sitter -*- lexical-binding: t; coding: utf-8 -*-

;; Copyright (C) 2020  Tuấn-Anh Nguyễn
;;
;; Author: Tuấn-Anh Nguyễn <ubolonton@gmail.com>
;;         Timo von Hartz <c0untlizzi@gmail.com>

;;; Commentary:

;; This file implements a new syntax highlighting based on `tree-sitter'.

;;; Code:

(require 'tree-sitter)

(defgroup tree-sitter-hl nil
  "Syntax highlighting using tree-sitter."
  :group 'tree-sitter)

(defgroup tree-sitter-hl-faces nil
  "All the faces of tree-sitter."
  :group 'tree-sitter-hl)

(defface tree-sitter-attribute-face '((default :inherit font-lock-preprocessor-face))
  "Face used for attribute"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-comment-face '((default :inherit font-lock-comment-face))
  "Face used for comment"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-constant-face '((default :inherit font-lock-constant-face))
  "Face used for constant"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-constant-builtin-face '((default :inherit font-lock-builtin-face))
  "Face used for constant.builtin"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-constructor-face '((default :inherit font-lock-variable-name-face))
  "Face used for constructor"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-escape-face '(())
  "Face used for escape"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-function-face '((default :inherit font-lock-function-name-face))
  "Face used for function"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-function-builtin-face '((default :inherit font-lock-builtin-face))
  "Face used for function.builtin"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-function-macro-face '((default :inherit font-lock-function-name-face))
  "Face used for function.macro"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-function-method-face '((default :inherit font-lock-function-name-face))
  "Face used for function.method"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-identifier-face '((default :inherit font-lock-function-name-face))
  "Face used for identifier"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-keyword-face '((default :inherit font-lock-keyword-face))
  "Face used for keyword"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-label-face '((default :inherit font-lock-preprocessor-face))
  "Face used for label"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-operator-face '((default :inherit font-lock-keyword-face))
  "Face used for operator"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-property-face '((default :inherit font-lock-variable-name-face))
  "Face used for property"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-punctuation-face '(())
  "Face used for punctuation"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-punctuation-bracket-face '(())
  "Face used for punctuation.bracket"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-punctuation-delimiter-face '(())
  "Face used for punctuation.delimiter"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-string-face '((default :inherit font-lock-string-face))
  "Face used for string"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-type-face '((default :inherit font-lock-type-face))
  "Faced used for type"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-type-builtin-face '((default :inherit font-lock-builtin-face))
  "Face used for type.builtin"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-variable-face '((default :inherit font-lock-variable-name-face))
  "Face used for variable"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-variable-builtin-face '((default :inherit font-lock-builtin-face))
  "Face used for variable.builtin"
  :group 'tree-sitter-hl-faces)

(defface tree-sitter-variable-parameter-face '((default :inherit font-lock-variable-name-face))
  "Faced used for variable.parameter"
  :group 'tree-sitter-hl-faces)

(defcustom tree-sitter-hl-default-faces
  '(("attribute"             . tree-sitter-attribute-face)
    ("comment"               . tree-sitter-comment-face)
    ("constant"              . tree-sitter-constant-face)
    ("constant.builtin"      . tree-sitter-constant-builtin-face)
    ("constructor"           . tree-sitter-constructor-face)
    ("escape"                . tree-sitter-escape-face)
    ("function"              . tree-sitter-function-face)
    ("function.builtin"      . tree-sitter-function-builtin-face)
    ("function.macro"        . tree-sitter-function-macro-face)
    ("function.method"       . tree-sitter-function-method-face)
    ("identifier"            . tree-sitter-identifier-face)
    ("keyword"               . tree-sitter-keyword-face)
    ("label"                 . tree-sitter-label-face)
    ("operator"              . tree-sitter-operator-face)
    ("property"              . tree-sitter-property-face)
    ("punctuation"           . tree-sitter-punctuation-face)
    ("punctuation.bracket"   . tree-sitter-punctuation-bracket-face)
    ("punctuation.delimiter" . tree-sitter-punctuation-delimiter-face)
    ("string"                . tree-sitter-string-face)
    ("type"                  . tree-sitter-type-face)
    ("type.builtin"          . tree-sitter-type-builtin-face)
    ("variable"              . tree-sitter-variable-face)
    ("variable.builtin"      . tree-sitter-variable-builtin-face)
    ("variable.parameter"    . tree-sitter-variable-parameter-face))
  "Alist of query identifier to face used for highlighting matches."
  :type '(alist :key-type string
                :value-type face)
  :group 'tree-sitter-hl)

(defvar-local tree-sitter-hl--query nil)
(defvar-local tree-sitter-hl--query-cursor nil)

(defun tree-sitter-hl--face (capture-name)
  (map-elt tree-sitter-hl-default-faces capture-name nil #'string=))

(defun tree-sitter-hl--highlight-capture (capture)
  (pcase-let* ((`(,name . ,node) capture)
               (face (map-elt tree-sitter-hl-default-faces name nil #'string=))
               (`(,beg . ,end) (ts-node-position-range node)))
    ;; (message " %s <- %s <- [%s %s]" face name beg end)
    (when face
      (put-text-property beg end 'face face)
      ;; Naive `add-face-text-property' keeps adding the same face, slowing
      ;; things down.
      ;; (add-face-text-property beg end face)
      )))

(defun tree-sitter-hl--highlight-region (beg end &optional _loudly)
  (message "tree-sitter-hl [%s %s]" beg end)
  (ts--save-context
    (ts-set-point-range tree-sitter-hl--query-cursor
                        (ts--point-from-position beg)
                        (ts--point-from-position end))
    (let* ((root-node (ts-root-node tree-sitter-tree))
           (captures (ts-query-captures
                      tree-sitter-hl--query
                      root-node
                      tree-sitter-hl--query-cursor
                      nil
                      #'ts--node-text)))
      ;; TODO: Handle quitting.
      (with-silent-modifications
        (font-lock-unfontify-region beg end)
        ;; TODO: Handle uncaptured nodes.
        (seq-do #'tree-sitter-hl--highlight-capture captures))
      ;; TODO: Return the actual region being fontified.
      nil)))

(defvar tree-sitter-hl--changed-ranges)


(defun tree-sitter-hl--extend-after-change-region (beg end _old-len)
  "Hook meant for `jit-lock-after-change-extend-region-functions'.
This relies on `tree-sitter-hl--record-changed-ranges' to have been run first."
  (when (bound-and-true-p tree-sitter-hl--changed-ranges)
    (message "tree-sitter-hl extend %s %s" beg end)
    (seq-doseq (range tree-sitter-hl--changed-ranges)
      (pcase-let ((`[,beg-byte ,end-byte] range))
        (setq beg (min beg (byte-to-position beg-byte)))
        (setq end (min end (byte-to-position end-byte)))))
    (message "                      %s %s" beg end)
    ;; TODO: Just set it to nil?
    (makunbound 'tree-sitter-hl--changed-ranges)
    `(,beg . ,end)))

(defun tree-sitter-hl--record-changed-ranges (old-tree)
  (message "tree-sitter-hl record")
  ;; TODO: What happens if more changes are made before these changes are
  ;; handled?
  (setq tree-sitter-hl--changed-ranges
        (ts-changed-ranges old-tree tree-sitter-tree)))

(defun tree-sitter-hl--invalidate-ranges (old-tree)
  (when old-tree
    (seq-doseq (range (ts-changed-ranges old-tree tree-sitter-tree))
      ;; TODO: How about invalidating a single large range?
      (pcase-let* ((`[,beg-byte ,end-byte] range)
                   (beg (byte-to-position beg-byte))
                   (end (byte-to-position end-byte)))
        (message "tree-sitter-hl invalidate [%s %s]" beg end)
        ;; TODO: How about calling `jit-lock-refontify' directly?
        (font-lock-flush beg end)))))

;;; This assumes both `tree-sitter-mode' and `font-lock-mode' were already
;;; enabled in the buffer.
(defun tree-sitter-hl--enable ()
  (unless tree-sitter-hl--query
    ;; XXX
    (let ((lang-symbol (alist-get major-mode tree-sitter-major-mode-language-alist)))
      (setq tree-sitter-hl--query (tree-sitter-hl--query-for lang-symbol))))

  (setq tree-sitter-hl--query-cursor (ts-make-query-cursor))

  ;; TODO: Override `font-lock-extend-after-change-region-function', or hook
  ;; into `jit-lock-after-change-extend-region-functions' directly. For that to
  ;; work, we need to make sure `tree-sitter--after-change' runs before
  ;; `jit-lock-after-change'.
  (add-hook 'tree-sitter-after-change-functions
            #'tree-sitter-hl--invalidate-ranges
            nil :local)

  ;; (add-hook 'tree-sitter-after-change-functions
  ;;           #'tree-sitter-hl--record-changed-ranges
  ;;           nil :local)
  ;; (add-function :override (local 'font-lock-extend-after-change-region-function)
  ;;               #'tree-sitter-hl--extend-after-change-region)

  ;; XXX
  (add-function :override (local 'font-lock-fontify-region-function)
                #'tree-sitter-hl--highlight-region)

  (font-lock-flush))

(defun tree-sitter-hl--disable ()
  (remove-function (local 'font-lock-fontify-region-function)
                   #'tree-sitter-hl--highlight-region)

  ;; (remove-function (local 'font-lock-extend-after-change-region-function)
  ;;                  #'tree-sitter-hl--extend-after-change-region)
  ;; (remove-hook 'tree-sitter-after-change-functions
  ;;              #'tree-sitter-hl--record-changed-ranges)

  (setq tree-sitter-hl--query-cursor nil)
  (setq tree-sitter-hl--query nil)

  (font-lock-flush))

;;; XXX
(defun tree-sitter-hl--query-for (lang-symbol)
  (let* ((query-path (concat
                      (file-name-directory (locate-library "tree-sitter-langs"))
                      (format "/repos/tree-sitter-%s/queries/highlights.scm"
                              lang-symbol)))
         (query-string (with-temp-buffer
                         (insert-file-contents query-path)
                         (buffer-string))))
    (ts-make-query (tree-sitter-require lang-symbol) query-string)))

(provide 'tree-sitter-hl)
;;; tree-sitter-hl.el ends here