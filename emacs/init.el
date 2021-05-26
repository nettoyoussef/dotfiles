;; -*- lexical-binding: t -*-

;;(require 'package)

;;(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
;;                    (not (gnutls-available-p))))
;;       (proto (if no-ssl "http" "https")))
;;  (when no-ssl (warn "\
;;Your version of Emacs does not support SSL connections,
;;which is unsafe because it allows man-in-the-middle attacks.
;;There are two things you can do about this warning:
;;1. Install an Emacs version that does support SSL and be safe.
;;2. Remove this warning from your init file so you won't see it again."))
;;  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
;;  ;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;;  ;; and `package-pinned-packages`. Most users will not need or want to do this.
;;  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
;;)

;; this allows for straight-version
;; this makes a faster initial time, but only check packages 
;; modified in a Emacs buffer
(setq straight-check-for-modifications '(check-on-save find-when-checking))

;; Use Straight for package installation / management
;; Bootstrap just enough to load configuration from a "literate" org-mode file
;; https://github.com/raxod502/straight.el/
(setq straight-repository-branch "develop")
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
       user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))




;; Install use-package
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(use-package diminish)
(use-package bind-key :straight use-package)

;; set file for custom variables
(setq custom-file (locate-user-emacs-file ".emacs-custom.el"))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file)

;; This needs to be before loading config.org so I don't have to give
;; permission to load the file when it is symlinked.
(customize-set-variable
 'vc-follow-symlinks t "Follow Symlinks without asking")

;; Load configuration
;; TODO: Figure out how to make byte compilation work?
;; (let ((config-el (expand-file-name "config.el" user-emacs-directory))
;;       (config-org (expand-file-name "config.org" user-emacs-directory)))
;;   (if (and (file-exists-p config-el)
;;            (time-less-p (file-attribute-modification-time (file-attributes config-org))
;;                         (file-attribute-modification-time (file-attributes config-el))))
;;         (load-file config-el)
;;     (org-babel-load-file config-org)))



;(package-initialize) ;; only use with package.el, not straight.el

;; manually set load path
;;source: https://github.com/gilbertw1/emacs-literate-starter/blob/master/emacs.org#emacs-initialization
;;(eval-and-compile
;;  (setq load-path (append load-path (directory-files package-user-dir t "^[^.]" t))))

;; We load cask early to allow overriding built-in packages.
;;
;; Specifically, we need to initialize cask before calling
;; 'org-babel-load-file, in order to prevent the built-in org
;; being loaded.
;;(add-to-list 'load-path (locate-user-emacs-file "cask/elpa"))
;;(require 'cask "~/.cask/cask.el")
;;(cask-initialize)


;;(org-babel-load-file (locate-user-emacs-file "config.org"))
;;(org-babel-load-file (locate-user-emacs-file "minimal_config.org"))

;; only with use package 
;;  (unless (package-installed-p 'use-package)
;;    (package-refresh-contents)
;;    (package-install 'use-package))

;;(eval-when-compile
;;  (require 'use-package))

;; set garbage collection to a higher to reduce initialization time
;;source: https://emacs.stackexchange.com/questions/2286/what-can-i-do-to-speed-up-my-start-up
(add-hook 'emacs-startup-hook 'my/set-gc-threshold)
(defun my/set-gc-threshold ()
  "Reset `gc-cons-threshold' to its default value."
  (setq gc-cons-threshold 
   100000000 ;; lsp-value
   ;; 800000 ;; original value
  )
)

;; manually set load path
;;source: https://github.com/gilbertw1/emacs-literate-starter/blob/master/emacs.org#emacs-initialization
;;(eval-and-compile
;;  (setq load-path (append load-path (directory-files package-user-dir t "^[^.]" t))))

;; doom's disable of file-name-handler-alist
 (defvar doom--file-name-handler-alist file-name-handler-alist)
 (setq file-name-handler-alist nil)

;; restore file-name-handler-alist:
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq file-name-handler-alist doom--file-name-handler-alist)))

(use-package tramp
  :config
  (require 'tramp)
  
  (custom-set-variables
   '(tramp-default-method "ssh")
   '(tramp-default-user "eliasy")
   '(tramp-default-host "cedro.lbic.fee.unicamp.br")
   )
)

(use-package docker-tramp
  :config
  (require 'docker-tramp)
)

(electric-indent-mode 0)

(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq delete-old-versions -1)
(setq version-control t)
(setq vc-make-backup-files t)
(setq auto-save-default t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)))

(fset 'yes-or-no-p 'y-or-n-p)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(set-face-attribute 'default nil :height 120)

;; Use a hook so the message doesn't get clobbered by other messages.
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

(use-package esup
  ;;  ;;:defer t
  ;; To use MELPA Stable use ":pin mepla-stable",
  ;;:pin melpa
  ;;:commands (esup)
  :config
;; Work around a bug where esup tries to step into the byte-compiled
;; version of `cl-lib', and fails horribly.
;;source: https://github.com/jschaf/esup/issues/54#issuecomment-651247749
 (setq esup-depth 0)
)

;; USE THIS
;;use-package version doesn't work
;;(straight-use-package 'esup)
;;(setq esup-depth 0)

;; add bullets to org preview
;; (use-package org-bullets
;;;;   :defer t
;;   :after org
;;   :init
;;   (add-hook 'org-mode-hook #'org-bullets-mode))

(use-package org-superstar ; "prettier" bullets
  :hook (org-mode . org-superstar-mode)
)

(use-package org-fragtog 
  :defer t
  :after org
  :init
  (add-hook 'org-mode-hook 'org-fragtog-mode)
)

(use-package htmlize
  :defer t
  :after org
)

(use-package org-ref 
  :defer t
  :after org
  :config
  ;; set default directories
  (setq reftex-default-bibliography '("/home/eliasy/notes/zettelkasten/bibliography/full_library.bib"))
  ;; see org-ref for use of these variables
  (setq org-ref-bibliography-notes "/home/eliasy/notes/zettelkasten/"
        org-ref-default-bibliography '("/home/eliasy/notes/zettelkasten/bibliography/full_library.bib")
  )
  ;; org latex build format (necessary to output the citation in latex)
  (setq org-latex-pdf-process
        '("pdflatex -interaction nonstopmode -output-directory %o %f"
    	  "bibtex %b"
    	  "pdflatex -interaction nonstopmode -output-directory %o %f"
    	  "pdflatex -interaction nonstopmode -output-directory %o %f"))
)

;; enable and install helm
(use-package helm-bibtex
  :defer t
  :after helm
  :config
  (setq bibtex-completion-bibliography "/home/eliasy/notes/zettelkasten/bibliography/full_library.bib")
  (setq bibtex-completion-notes-path "/home/eliasy/notes/zettelkasten/")
)

(defun capture-note (path)
   (let ((name (read-string "Name: ")))
     (expand-file-name (format "%s.org"  name) path)
   )
 )
(defun ey--load-org-capture-templates ()
 (setq org-capture-templates
 ;; Never forget: you must include a star (*) top heading in the template
  '(
    ("n" "note")
    ("nb"
     "bibliography"
     plain 
     (file (lambda () (capture-note "~/notes/zettelkasten/bibliography")))
 "#+SETUPFILE: ~/notes/zettelkasten/css/setup.config 
 #+INTERLEAVE_PDF: %^{Path of the file} 
 #+BIBLIOGRAPHY:/home/eliasy/notes/zettelkasten/bibliography/full_library.bib plain option:-d
 #+TITLE: %^{Title of the note}
 #+BEGIN_VERSE
 :AUTHORS: %^{Who are the authors?}
 :PAPER_TYPE: %^{What type is the paper? |Empirical|Theoretical|Both}
 :PERIOD: %^{Which period the paper covers, if empirical? |NA}
 :COUNTRY: %^{Which countries the paper covers, if empirical? (separated by semicollon) |NA}
 :DATA_TYPE: %^{What is the data type (time-series, panel, cross-section)? |NA|panel data|time-series|cross-section}
 :DATASETS: %^{What are the datasets/surveys used in their country denomination, if available?|NA}
 :DISAGGREGATION_LVL: %^{What is the level of disaggregation of the data (firm, individual, city, state, country)? |NA|firm|individual|city|state|country}
 :N_OBS: %^{What is the number of observations, if empirical? |NA}
 :ISIC: %^{What are the ISIC sectors covered, if empirical and at the industry/firm level?|NA|10-33}
 :DEP_VAR: %^{What are the main dependent variables, if empirical? |NA}
 :INDEP_VAR: %^{What are the main independent variables, if empirical? |NA}
 :EST: %^{What are the estimators used, if empirical? |NA}
 :MODEL: %^{Is there a theoretical model in the paper? |y|n}
 :REVIEW: %^{Is it a literature review, if theoretical? |y|n}
 :RESULTS: %^{Fill with results worth saving, if necessary |NA}
 :CONCL: %^{Fill with paper's main conclusion, if possible |NA}
 :TAGS: %^{Fill with other tags, if necessary |NA}
 #+END_VERSE
 \n* Notes
 %? 
 bibliography:/home/eliasy/notes/zettelkasten/bibliography/full_library.bib 
 bibliographystyle:apacite
 "
 ;; Other useful options
 ;;#+LATEX_HEADER: \setlist[itemize]{noitemsep, topsep=0pt}
 ;;#+LATEX_HEADER: \setlist[enumerate]{noitemsep, topsep=0pt}
 )
     ("nn" 
     "new parent note"
     plain 
     (file (lambda () (capture-note "~/notes/zettelkasten")))
 "
 #+SETUPFILE: ~/notes/zettelkasten/css/setup.config
 #+BIBLIOGRAPHY:/home/eliasy/notes/zettelkasten/bibliography/full_library.bib plain option:-d
 #+TITLE: %^{Title of the note}
 :TAGS: %^{Fill with other tags, if necessary |NA}
 \n* Notes
 %? 
 bibliography:/home/eliasy/notes/zettelkasten/bibliography/full_library.bib
 bibliographystyle:apacite
 "
 )

    ("a" "agenda")
    ("at" "todo" entry (file "~/notes/to-do-list.org")
     "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
    ("am" "Meeting" entry (file "~/notes/to-do-list.org")
     "* Meeting with %? :MEETING:\n" :clock-in t :clock-resume t)
    ("an" "Next Task" entry (file "~/notes/to-do-list.org")
     "** NEXT %? \nDEADLINE: %t")

;;    ("at" 
;;     "to-do list"
;;     entry 
;;     (file "~/notes/to-do-list.org")
;; "* TODO %?")
   )
 )
)

;; == Capture Mode Settings ==
;; Define the custum capture templates
;;(defvar org-capture-templates
;;	 ("n" "Next Task" entry (file+headline org-default-notes-file "Tasks")
;;	  "** NEXT %? \nDEADLINE: %t")

;;(use-package ox-publish 
;;;;  :config
(defun ey--load-org-directory ()
  (setq org-publish-project-alist
   '(
       ;; ... add all the components here (see below)...

;;     ("zettel-inherit"
;;      :base-directory "~/notes/zettelkasten/css"
;;      :recursive t
;;      :base-extension "css\\|js"
;;      :publishing-directory "~/notes/zettelkasten_html/"
;;      :publishing-function org-publish-attachment
;;     )
     
     ("org-notes"
       :base-directory "~/notes/zettelkasten"
       :base-extension "org"
       :publishing-directory "~/notes/zettelkasten_html/"
       :recursive t
       :publishing-function org-html-publish-to-html
       :headline-levels 4             ; Just the default for this project.
       :auto-preamble t
     )

     ("org-static"
      :base-directory "~/notes/zettelkasten"
      ;;:base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
      :base-extension "png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
      :publishing-directory "~/notes/zettelkasten_html/"
      :recursive t
      :publishing-function org-publish-attachment
      )

     ("org" :components ("org-notes" "org-static"))
     
    )
  )
)
;;)

(defun ey--load-org-latex-packages () 
(add-to-list 'org-latex-packages-alist '("" "cancel" t)) ;; add strike-lines for equations
(add-to-list 'org-latex-packages-alist '("margin=3cm" "geometry" t)) ;; stretch margins
(add-to-list 'org-latex-packages-alist '("" "parskip" t)) ;; add space between paragraphs
(add-to-list 'org-latex-packages-alist '("" "enumitem" t)) ;; remove space between bullets
;;(add-to-list 'org-latex-packages-alist '("round" "natbib" t)) ;; add package for bibliography
(add-to-list 'org-latex-packages-alist '("natbibapa" "apacite" t)) ;; add package for bibliography
(add-to-list 'org-latex-packages-alist '("" "lmodern" t)) ;; correctly copyable characters from pdf output 
(add-to-list 'org-latex-packages-alist '("" "cmap" t)) ;; correctly copyable characters from pdf output
(add-to-list 'org-latex-packages-alist '("portuguese" "babel" t)) ;; correctly copyable characters from pdf output
(add-to-list 'org-latex-packages-alist '("" "booktabs" t)) ;; links with color
(add-to-list 'org-latex-packages-alist '("" "minted" t)) ;; highlight code syntax
(add-to-list 'org-latex-packages-alist '("" "color" t)) ;; highlight code syntax
(add-to-list 'org-latex-packages-alist '("colorlinks = true, linkcolor=blue" "hyperref" t)) ;; links with blue color, hyperref must always come after minted
(setq org-latex-listings 'minted) ;; highlight code syntax
(add-to-list 'org-latex-packages-alist '("" "amsthm" t)) ;; makes for nice theorems and proof environments 
)

(defun ey--load-org-babel-config ()
 (setq org-confirm-babel-evaluate nil
       org-src-fontify-natively t
 ;;      org-src-tab-acts-natively t
 )

 (custom-set-variables
  '(org-babel-load-languages 
    (quote (
     (emacs-lisp . t) 
     (R          . t)
     (python     . t)
     (shell      . t)
     )
    )
   )
  '(org-confirm-babel-evaluate nil)
 )
)

;;(use-package org-tempo
;;;;  :config
(defun ey--load-org-babel-templates ()
  (add-to-list 'org-structure-template-alist '("sh" . "src sh"))
)
;;)

(load "~/.emacs.d/functions/org-agenda-functions")
;;(use-package org-agenda-functions
;; :load-path "~/.emacs.d/functions"
;;)

(defun ey--agenda_display () 

  ;; it is necessary to load the package directly
  ;; to access functions such as org-agenda-overriding-header
  ;;
  (require 'org-agenda)

  ;; Compact the block agenda view (disabled)
  (setq org-agenda-compact-blocks nil)

  ;; Set default column view headings: Task Effort Clock_Summary
  (setq org-columns-default-format "%50ITEM(Task) %10Effort(Effort){:} %10CLOCKSUM %16TIMESTAMP_IA")

  ;; Display properties

  ;; sets up tag alignment
  ;;(setq org-tags-column 8)
  ;;(setq org-agenda-tags-column org-tags-column)

  ;; see this answer: 
  ;; https://emacs.stackexchange.com/questions/44665/is-there-a-way-to-suggest-label-names-in-org-mode-latex-export
  ;; Use user-provided labels instead of internal ones when non-nil.
  ;; When this variable is non-nil, Org will use the value of CUSTOM_ID property,
  ;; NAME keyword or Org target as the key for the \label commands generated.
  ;; By default, Org generates its own internal labels during LaTeX export. 
  ;; This process ensures that the \label keys are unique and valid, but it means 
  ;; the keys are not available in advance of the export process.
  ;; Setting this variable gives you control over how Org generates labels during 
  ;; LaTeX export, so that you may know their keys in advance. One reason to do 
  ;; this is that it allows you to refer to various elements using a single label 
  ;; both in Org’s link syntax and in embedded LaTeX code. 
  ;;(setq org-latex-prefer-user-labels t)
 
  ;; child entries block change of status of parent entry
  ;; undone TODO entries will block switching the parent to DONE.
  ;; Also, if a parent has an :ORDERED: property, switching an entry to DONE will
  ;; be blocked if any prior sibling is not yet done.
  ;; Finally, if the parent is blocked because of ordered siblings of its own,
  ;; the child will also be blocked.
  ;; blocked tasks (and other settings)
  (setq org-enforce-todo-dependencies t)
  
  ;; Allow setting single tags without the menu
  ;; (setq org-fast-tag-selection-single-key 'expert)
  
  ;; Include the todo keywords
  ;;(setq org-fast-tag-selection-include-todo t)

  ;; Set the times to display in the time grid
  (setq org-agenda-time-grid
        (quote
         ((daily today remove-match)
          (800 1200 1600 2000)
          "......" "----------------")))

   ;; Custom colors for the keywords
   (setq org-todo-keyword-faces
         '(("TODO" :foreground "red" :weight bold)
           ("TASK" :foreground "#5C888B" :weight bold)
           ("NEXT" :foreground "blue" :weight bold)
           ("PROJ" :foreground "magenta" :weight bold)
           ("MOTIVATOR" :foreground "#F06292" :weight bold)
           ("DONE" :foreground "forest green" :weight bold)
           ("WAITING" :foreground "orange" :weight bold)
           ("INACTIVE" :foreground "magenta" :weight bold)
           ("SOMEDAY" :foreground "cyan" :weight bold)
           ("CANCELLED" :foreground "forest green" :weight bold)))

  ;;;; Agenda block definitions
  
  (defvar gs-org-agenda-block--today-schedule
    '(agenda "" ((org-agenda-overriding-header "Today's Schedule:")
  	       (org-agenda-span 'day)
  	       (org-agenda-ndays 1)
  	       (org-agenda-start-on-weekday nil)
  	       (org-agenda-start-day "+0d")))
    "A block showing a 1 day schedule.")
  
  (defvar gs-org-agenda-block--weekly-log
    '(agenda "" ((org-agenda-overriding-header "Weekly Log")))
    "A block showing my schedule and logged tasks for this week.")
  
  (defvar gs-org-agenda-block--previous-calendar-data
    '(agenda "" ((org-agenda-overriding-header "Previous Calendar Data (last 3 weeks)")
  	       (org-agenda-start-day "-21d")
  	       (org-agenda-span 21)
  	       (org-agenda-start-on-weekday nil)))
    "A block showing my schedule and logged tasks for the last few weeks.")
  
  (defvar gs-org-agenda-block--upcoming-calendar-data
    '(agenda "" ((org-agenda-overriding-header "Upcoming Calendar Data (next 2 weeks)")
  	       (org-agenda-start-day "0d")
  	       (org-agenda-span 14)
  	       (org-agenda-start-on-weekday nil)))
    "A block showing my schedule for the next couple weeks.")
  
;;  (defvar gs-org-agenda-block--refile
;;    '(tags "REFILE-ARCHIVE-REFILE=\"nil\"|INFO"
;;  	 ((org-agenda-overriding-header "Headings needing refiling or other info:")
;;  	  (org-tags-match-list-sublevels nil)))
;;    "Headings needing refiling or other info.")
  
  (defvar gs-org-agenda-block--next-tasks
    '(tags-todo "-INACTIVE-SOMEDAY-CANCELLED-ARCHIVE/!NEXT"
  	      ((org-agenda-overriding-header "Next Tasks:")
  	       ))
    "Next tasks.")
  
  (defvar gs-org-agenda-block--active-projects
    '(tags-todo "-INACTIVE-SOMEDAY-CANCELLED-REFILEr/!"
  	      ((org-agenda-overriding-header "Active Projects:")
  	       (org-agenda-skip-function 'gs/select-projects)))
    "All active projects: no inactive/someday/cancelled/refile.")
  
  (defvar gs-org-agenda-block--standalone-tasks
    '(tags-todo "-INACTIVE-SOMEDAY-CANCELLED-REFILE-ARCHIVE-STYLE=\"habit\"/!-NEXT"
  	      ((org-agenda-overriding-header "Standalone Tasks:")
  	       (org-agenda-skip-function 'gs/select-standalone-tasks)))
    "Tasks (TODO) that do not belong to any projects.")
  
  (defvar gs-org-agenda-block--waiting-tasks
    '(tags-todo "-INACTIVE-SOMEDAY-CANCELLED-ARCHIVE/!WAITING"
  	     ((org-agenda-overriding-header "Waiting Tasks:")
  	      ))
    "Tasks marked as waiting.")
  
  (defvar gs-org-agenda-block--remaining-project-tasks
    '(tags-todo "-INACTIVE-SOMEDAY-CANCELLED-WAITING-REFILE-ARCHIVE/!-NEXT"
  	      ((org-agenda-overriding-header "Remaining Project Tasks:")
  	       (org-agenda-skip-function 'gs/select-project-tasks)))
    "Non-NEXT TODO items belonging to a project.")
  
  (defvar gs-org-agenda-block--inactive-tags
    '(tags-todo "-SOMEDAY-ARCHIVE-CANCELLED/!INACTIVE"
  	 ((org-agenda-overriding-header "Inactive Projects and Tasks")
  	  (org-tags-match-list-sublevels nil)))
    "Inactive projects and tasks.")
  
  (defvar gs-org-agenda-block--someday-tags
    '(tags-todo "-INACTIVE-ARCHIVE-CANCELLED/!SOMEDAY"
  	 ((org-agenda-overriding-header "Someday Projects and Tasks")
  	  (org-tags-match-list-sublevels nil)))
    "Someday projects and tasks.")
  
  (defvar gs-org-agenda-block--end-of-agenda
    '(tags "ENDOFAGENDA"
  	 ((org-agenda-overriding-header "End of Agenda")
  	  (org-tags-match-list-sublevels nil)))
    "End of the agenda.")
  
  (defvar gs-org-agenda-display-settings
    '((org-agenda-start-with-log-mode t)
      (org-agenda-log-mode-items '(clock))
      (org-agenda-prefix-format '((agenda . "  %-12:c%?-12t %(gs/org-agenda-add-location-string)% s")
  				(timeline . "  % s")
  				(todo . "  %-12:c %(gs/org-agenda-prefix-string) ")
  				(tags . "  %-12:c %(gs/org-agenda-prefix-string) ")
  				(search . "  %i %-12:c")))
      (org-agenda-todo-ignore-deadlines 'near)
      (org-agenda-todo-ignore-scheduled t))
    "Display settings for my agenda views.")
  
  (defvar gs-org-agenda-entry-display-settings
    '(,gs-org-agenda-display-settings
      (org-agenda-entry-text-mode t))
    "Display settings for my agenda views with entry text.")

  ;;;; Agenda Definitions
  (setq org-agenda-custom-commands
        `(
;;          ("h" "Habits" agenda "STYLE=\"habit\""
;;           ((org-agenda-overriding-header "Habits")
;;            (org-agenda-sorting-strategy
;;             '(todo-state-down effort-up category-keep))))
          ("d" "My schedule"                       ;; key + description
           (,gs-org-agenda-block--today-schedule
 ;;           ,gs-org-agenda-block--refile
            ,gs-org-agenda-block--next-tasks
            ,gs-org-agenda-block--active-projects
            ,gs-org-agenda-block--end-of-agenda)   ;; desc
           ,gs-org-agenda-display-settings)
          ("L" "Weekly Log"
           (,gs-org-agenda-block--weekly-log)
           ,gs-org-agenda-display-settings)
          ("r " "Agenda Review (all)"
           (,gs-org-agenda-block--next-tasks
;;            ,gs-org-agenda-block--refile
            ,gs-org-agenda-block--active-projects
            ,gs-org-agenda-block--standalone-tasks
            ,gs-org-agenda-block--waiting-tasks
            ,gs-org-agenda-block--remaining-project-tasks
            ,gs-org-agenda-block--inactive-tags
            ,gs-org-agenda-block--someday-tags
            ,gs-org-agenda-block--end-of-agenda)
           ,gs-org-agenda-display-settings)
          ("rn" "Agenda Review (next tasks)"
           (,gs-org-agenda-block--next-tasks
            ,gs-org-agenda-block--end-of-agenda)
           ,gs-org-agenda-display-settings)
          ("rp" "Agenda Review (previous calendar data)"
           (,gs-org-agenda-block--previous-calendar-data
            ,gs-org-agenda-block--end-of-agenda)
           ,gs-org-agenda-display-settings)
          ("ru" "Agenda Review (upcoming calendar data)"
           (,gs-org-agenda-block--upcoming-calendar-data
            ,gs-org-agenda-block--end-of-agenda)
           ,gs-org-agenda-display-settings)
          ("rw" "Agenda Review (waiting tasks)"
           (,gs-org-agenda-block--waiting-tasks
            ,gs-org-agenda-block--end-of-agenda)
           ,gs-org-agenda-display-settings)
          ("rP" "Agenda Review (projects list)"
           (,gs-org-agenda-block--active-projects
            ,gs-org-agenda-block--end-of-agenda)
           ,gs-org-agenda-display-settings)
          ("ri" "Agenda Review (someday and inactive projects/tasks)"
           (,gs-org-agenda-block--someday-tags
            ,gs-org-agenda-block--inactive-tags
            ,gs-org-agenda-block--end-of-agenda)
           ,gs-org-agenda-display-settings)
          ))



)

(defun ey--load-org-agenda ()

  ;; == General Config == 
  ;; set default agenda files
  (setq org-agenda-files '("~/notes/to-do-list.org"))
 
  ;; add time when item is closed 
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-log-state-notes-insert-after-drawers nil)
 
  ;; Allows the use of keybindings to
  ;; select tags
  (setq org-use-fast-todo-selection t)
 
  ;; set the possible states for each item type
  ;; keybindings are first item in parentheses
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "PROJ(p)" "|" "DONE(d)")
          (sequence "TASK(T)")
          (sequence "MEETING(M)" "|" "DONE(d)" "CANCELLED(c@/!)")
          (sequence "WAITING(w@/!)" "INACTIVE(i)" "SOMEDAY(s)" "|" "CANCELLED(c@/!)")
         )
  )


  ;; == Agenda Display == 

  ;; Custom Display  
  (ey--agenda_display)
  
  ;; Non-nil means agenda q key will bury agenda buffers.
  ;; Agenda commands will then show existing buffer instead of generating new ones.
  ;;When nil, ‘q’ will kill the single agenda buffer.
  ;;(setq org-agenda-sticky t)

  ;; When this variable is t, the initialization of the Org agenda
  ;; buffers is inhibited: e.g. the visibility state is not set, the
  ;; tables are not re-aligned, etc.
  ;; mainly for speed, see
  ;; https://orgmode.org/manual/Speeding-Up-Your-Agendas.html
  (setq org-agenda-inhibit-startup t)
 
  ;; Dim currently blocked TODOs in the agenda display.
  ;; When INVISIBLE is non-nil, hide currently blocked TODO instead of
  ;; dimming them.
  ;; mainly for speed, see
  ;; https://orgmode.org/manual/Speeding-Up-Your-Agendas.html
  (setq org-agenda-dim-blocked-tasks nil)

  ;; == Clock ==

  ;; set default task for punching in (in my case, the entry "organization")
  (defvar bh/organization-task-id "a2e954ce-bc30-454e-b4c2-3f90227fbbac")

  ;; Set task to a special todo state while clocking it.
  ;; The value should be the state to which the entry should be
  ;; switched.  If the value is a function, it must take one
  ;; parameter (the current TODO state of the item) and return the
  ;; state to switch it to.
  ;; If not a project, clocking-in changes TODO to NEXT
  (setq org-clock-in-switch-to-state 'bh/clock-in-to-next)

  ;; Show lot of clocking history so it's easy to pick items off the list 
  (setq org-clock-history-length 20)

  ;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks
  ;; with 0:00 duration
  (setq org-clock-out-remove-zero-time-clocks t)

  ;; Clock out when moving task to a done state
  (setq org-clock-out-when-done t)

  ;; global Effort estimate values
  ;; see https://orgmode.org/manual/Effort-Estimates.html
  (setq org-global-properties
        '(("Effort_ALL" .
           "0:15 0:30 0:45 1:00 1:30 2:00 2:30 3:00 4:00 5:00")))
  ;;        1    2    3    4    5    6    7    8    9    0
  ;; These are the hotkeys ^^
 
  ;; set allarm when effort for today runs out
  ;; see also repeated tasks in the manual
  ;; https://orgmode.org/manual/Repeated-tasks.html#Repeated-tasks
  (setq org-clock-sound "~/.emacs.d/tones/A-Tone.wav")

  ;; If idle for more than 15 minutes, resolve the things by asking what to do
  ;; with the clock time
  (setq org-clock-idle-time 15)

  ;; change clock default face when overrunning effort
  ;; source: https://www.reddit.com/r/orgmode/comments/aw9lqf/change_the_color_of_a_running_orgmode_timer/
  (set-face-attribute 'org-mode-line-clock-overrun nil :foreground "red2" :weight 'bold)
 
  ;; == Refile ==
  ;; Targets include this file and any file contributing to the agenda - up to 9 levels deep
  (setq org-refile-targets (quote ((nil :maxlevel . 9)
                                   (org-agenda-files :maxlevel . 9))))
  
  ;;  Be sure to use the full path for refile setup
  (setq org-refile-use-outline-path t)
  (setq org-outline-path-complete-in-steps nil)

  ;; Allow refile to create parent tasks with confirmation
  (setq org-refile-allow-creating-parent-nodes 'confirm)

  ;; Exclude DONE state tasks from refile targets
  (setq org-refile-target-verify-function 'bh/verify-refile-target)

  ;; set reminders for deadlines
  (setq org-deadline-warning-days 10)

  ;; == Tags ==
  ;; Auto-update tags whenever the state is changed
  (setq org-todo-state-tags-triggers
        '(("CANCELLED" ("CANCELLED" . t))
          ("WAITING" ("SOMEDAY") ("INACTIVE") ("WAITING" . t))
          ("INACTIVE" ("WAITING") ("SOMEDAY") ("INACTIVE" . t))
          ("SOMEDAY" ("WAITING") ("INACTIVE") ("SOMEDAY" . t))
          (done ("WAITING") ("INACTIVE") ("SOMEDAY"))
          ("TODO" ("WAITING") ("CANCELLED") ("INACTIVE") ("SOMEDAY"))
          ("TASK" ("WAITING") ("CANCELLED") ("INACTIVE") ("SOMEDAY"))
          ("NEXT" ("WAITING") ("CANCELLED") ("INACTIVE") ("SOMEDAY"))
          ("PROJ" ("WAITING") ("CANCELLED") ("INACTIVE") ("SOMEDAY"))
          ("MOTIVATOR" ("WAITING") ("CANCELLED") ("INACTIVE") ("SOMEDAY"))
          ("DONE" ("WAITING") ("CANCELLED") ("INACTIVE") ("SOMEDAY"))))

  ;;  (defun bh/org-auto-exclude-function (tag)
  ;;    "Automatic task exclusion in the agenda with / RET"
  ;;    (and (cond
  ;;          ((string= tag "hold")
  ;;           t)
  ;;          ((string= tag "farm")
  ;;           t))
  ;;         (concat "-" tag)))
  ;;  
  ;;  (setq org-agenda-auto-exclude-function 'bh/org-auto-exclude-function)

)

;; Fix evil-auto-indent for org buffers.
;; source: https://github.com/gjstein/emacs.d/blob/master/config/init-31-doc-org.el 
(defun ey--org-disable-evil-auto-indent nil
  "Disables evil's auto-indent for org."
  (setq evil-auto-indent nil)
)

(defun column-delimiter (n_char) 
  (progn
   (setq display-fill-column-indicator-column n_char)
   (setq display-fill-column-indicator "t")
   (display-fill-column-indicator-mode)
  )
)

(use-package org
  ;;  ;;:straight (:type built-in)
  ;;:straight (:local-repo nil)
  :defer 2
  :init
  ;; set line wrap at 90 characters
  (add-hook 'org-mode-hook 
    '(lambda () (column-delimiter 90))
  )

  ;; disable evil-auto-indent on org buffers - it reindents 
  ;; every time you add a new line with `o` or `i` + RET
  (add-hook 'org-mode-hook #'ey--org-disable-evil-auto-indent)

  ;; == Agenda Specific Hooks == 

  ;; Agenda post-processing
  ;; Highlight the "!!" for stuck projects (for emphasis)
  (add-hook 'org-agenda-finalize-hook 'gs/org-agenda-project-highlight-warning)

  ;; Remove empty agenda blocks
  (add-hook 'org-agenda-finalize-hook 'gs/remove-agenda-regions)

  :config
  ;; Set org default directories
  (ey--load-org-directory)

  ;; Highlight latex code 
  (setq org-highlight-latex-and-related '(latex script entities))
  
  ;; Display inline images
  (setq org-startup-with-inline-images t)


  ;; change display of verbatim to red highlight
  (add-to-list 'org-emphasis-alist
               '("=" (:foreground "red")
                 ))

  ;; set agenda config
  ;;(setq org-agenda-files '("~/notes/to-do-list.org"))
  (ey--load-org-agenda)

  ;; Toggle smart quotes (org-export-with-smart-quotes).
  ;; Depending on the language used, when activated, 
  ;; Org treats pairs of double quotes as primary quotes, 
  ;; pairs of single quotes as secondary quotes, and single quote marks as apostrophes. 
  (setq org-export-with-smart-quotes t)

  ;; load latex packages for preview
  (ey--load-org-latex-packages)

  ;; babel config
  (ey--load-org-babel-config)
  (ey--load-org-babel-templates)

  ;; org capture templates 
  (ey--load-org-capture-templates)

  ;; Edit size of inline preview of images in latex
  (setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))

 (defun hello ()
      "Hello World and you can call it via M-x hello."
      (interactive)
      (message "Hello World!"))
)

(defun ey-open-config () 
(interactive) (find-file "~/.emacs.d/config.org")
)

(defun ey-open-agenda () 
(interactive) (find-file "~/notes/to-do-list.org")
)

(defun ey-open-current-project () 
(interactive) (find-file "/docker:root@ab24f147537c:/home/eliasy/project_repositories")
)


(use-package hydra 
  :defer t
  :bind
  (
  ( "M-," . hydra-complete/body)
  ( "M-i" . hydra-helm-swoop/body)
  ( "M-0" . hydra-treemacs/body)
  )
  :config
  ;;:bind (("C-tab" . hydra-complete/body))
 ;; (defhydra hydra-org (:color pink
 ;;                      :hint nil)
 ;; "
 ;; ^Mark^             ^Unmark^           ^Actions^          ^Search
 ;; ^^^^^^^^-----------------------------------------------------------------
 ;; _m_: mark          _u_: unmark        _x_: execute       _R_: re-isearch
 ;; _s_: save          _U_: unmark up     _b_: bury          _I_: isearch
 ;; _d_: delete        ^ ^                _g_: refresh       _O_: multi-occur
 ;; _D_: delete up     ^ ^                _T_: files only: % -28`Buffer-menu-files-only
 ;; _~_: modified
 ;; "
 ;;   ("m" Buffer-menu-mark)
 ;;   ("u" Buffer-menu-unmark)
 ;;   ("U" Buffer-menu-backup-unmark)
 ;;   ("d" Buffer-menu-delete)
 ;;   ("D" Buffer-menu-delete-backwards)
 ;;   ("s" Buffer-menu-save)
 ;;   ("~" Buffer-menu-not-modified)
 ;;   ("x" Buffer-menu-execute)
 ;;   ("b" Buffer-menu-bury)
 ;;   ("g" revert-buffer)
 ;;   ("T" Buffer-menu-toggle-files-only)
 ;;   ("O" Buffer-menu-multi-occur :color blue)
 ;;   ("I" Buffer-menu-isearch-buffers :color blue)
 ;;   ("R" Buffer-menu-isearch-buffers-regexp :color blue)
 ;;   ("c" nil "cancel")
 ;;   ("v" Buffer-menu-select "select" :color blue)
 ;;   ("o" Buffer-menu-other-window "other-window" :color blue)
 ;;   ("q" quit-window "quit" :color blue)
 ;; )
 ;; (define-key Buffer-menu-mode-map "," 'hydra-org/body)

  (defhydra hydra-complete (:exit t)
    "
    Complete keybindings
    ^Mark^                        ^Actions^          
    ^^^^^^^^-----------------------------------------------------------------------
    _,_: yankpad-expand                       expand snippet 
    _h_: ess-display-help-on-object           open ess help for object at point
    _r_: ess-eval-region                      execute selection on R buffer
    _j_: dumb-jump-hydra                      go to dumb-jump-hydra
    _c_: comint-clear-buffer                  clear the buffer of the shell/process 
    _d_: hydra-ess-debug                      go to ess-debug hydra
    _p_  hydra-ess-package                    go to ess-package functions
    "

    (","  yankpad-expand)
    ("h"  ess-display-help-on-object)
    ("r"  ess-eval-region)
    ("j"  dumb-jump-hydra/body)
    ("c"  comint-clear-buffer)
    ("d"  hydra-ess-debug/body)
    ("p"  hydra-ess-package/body)
  )

  (defhydra dumb-jump-hydra (:color blue :columns 3)
    "
    dumb-jump keybindings
    ^Mark^                        ^Actions^          
    ^^^^^^^^-----------------------------------------------------------------------
    _g_: dumb-jump-go                                 go to definition           
    _o_: dumb-jump-go-other-window                    definition on new window     
    _e_: dumb-jump-go-prefer-external                 favor definitions in other buffers          
    _x_: dumb-jump-go-prefer-external-other-window    same as above but in a new window    
    _p_: dumb-jump-go-prompt                          asks which function to jump          
    _l_: dumb-jump-quick-look                         show tooltip with the definition           
    _b_: dumb-jump-back                               go back to the point before jump           
    _q_: quit                       
    "

    ("g" dumb-jump-go                              "Go")
    ("o" dumb-jump-go-other-window                 "Other window")
    ("e" dumb-jump-go-prefer-external              "Go    external")
    ("x" dumb-jump-go-prefer-external-other-window "Go    external other window")
    ("p" dumb-jump-go-prompt                       "Prompt")
    ("l" dumb-jump-quick-look                      "Quick look")
    ("b" dumb-jump-back                            "Back")
    ("q"  nil "quit" :color blue)
  )

  (defhydra hydra-ess-debug ()
    "
    Ess-debug keybindings
    ^Mark^                        ^Actions^          
    ^^^^^^^^-----------------------------------------------------------------------
    _c_: ess-debug-command-continue           debug: Continue           
    _m_: ess-debug-command-continue-multi     debug: Continue multi     
    _n_: ess-debug-command-next               debug: Next step          
    _M_: ess-debug-command-next-multi         debug: Next step multi    
    _u_: ess-debug-command-up                 debug: Up frame           
    _t_: ess-debug-command-quit               debug: Quit debugging     
    _q_: quit                       
    "

    ("c"  ess-debug-command-continue)
    ("m"  ess-debug-command-continue-multi)
    ("n"  ess-debug-command-next)
    ("M"  ess-debug-command-next-multi)
    ("u"  ess-debug-command-up)
    ("t"  ess-debug-command-quit)
    ("q"  nil "quit" :color blue)
  )


  (defhydra hydra-ess-package ()
    "
    Ess-debug keybindings
    ^Mark^                        ^Actions^          
    ^^^^^^^^-----------------------------------------------------------------------
    _c_: ess-debug-command-continue           debug: Continue           
    _m_: ess-debug-command-continue-multi     debug: Continue multi     
    _n_: ess-debug-command-next               debug: Next step          

    ^check^                        ^Actions^          
    _c_: ess-r-devtools-check-package
    _w_: ess-r-devtools-check-with-winbuilder
    _r_: ess-r-rhub-check-package

    ^build/load/install^                        ^Actions^          
    _b_: ess-r-devtools-build
    _i_: ess-r-devtools-install-package
    _l_: ess-r-devtools-load-package
    _u_: ess-r-devtools-unload-package

    ^document/test^                        ^Actions^          
    _d_: ess-r-devtools-document-package
    _t_: ess-r-devtools-test-package

    ^other^                        ^Actions^          
    _e_: ess-r-devtools-execute-command
    _v_: ess-r-set-evaluation-env
    _g_: ess-r-devtools-install-github
    _q_: quit                       
    "

    ("c" ess-r-devtools-check-package)
    ("w" ess-r-devtools-check-with-winbuilder)
    ("r" ess-r-rhub-check-package)
    ("b" ess-r-devtools-build)
    ("i" ess-r-devtools-install-package)
    ("l" ess-r-devtools-load-package)
    ("u" ess-r-devtools-unload-package)
    ("d" ess-r-devtools-document-package)
    ("t" ess-r-devtools-test-package)
    ("e" ess-r-devtools-execute-command)
    ("v" ess-r-set-evaluation-env)
    ("g" ess-r-devtools-install-github)
    ("q"  nil "quit" :color blue)
  )

  (defhydra hydra-helm-swoop ()
    "
    Swoop keybindings
    ^Mark^                        ^Actions^          
    ^^^^^^^^-----------------------------------------------------------------------
    _i_: 'helm-swoop               open search at selection/cursor  
    _I_: 'helm-swoop-back          Go to the last pos. where swoop was called   
    _m_: 'helm-multi-swoop         search in all selected buffers    
    _M_: 'helm-multi-swoop-all     search in all buffers   
    _q_: quit                       
    "
    ("i"  helm-swoop)
    ("I"  helm-swoop-back-to-last-point)
    ("m"  helm-multi-swoop)
    ("M"  helm-multi-swoop-all)
    ("q"  nil "quit" :color blue)
  )


  (defhydra hydra-helm ()
    "
    Swoop keybindings
    ^Mark^                        ^Actions^          
    ^^^^^^^^-----------------------------------------------------------------------
    _i_: 'helm-swoop               open search at selection/cursor  
    _I_: 'helm-swoop-back          Go to the last pos. where swoop was called   
    _m_: 'helm-multi-swoop         search in all selected buffers    
    _M_: 'helm-multi-swoop-all     search in all buffers   
    _q_: quit                       
    "
    ("1"  'helm-all-mark-rings)
    ("2"  'helm-register)
    ("2"  'helm-top)
    ("2"  'helm-google-suggest)
    ("q"  nil "quit" :color blue)
  )


  (defhydra hydra-treemacs ()
    "
    Treemacs keybindings
    ^Mark^                                  ^Actions^          
    ^^^^^^^^------------------------------------------------------------------------------
    _0_: 'treemacs-select-window            open search at selection/cursor  
    _t_: 'treemacs                         Go to the last pos. where swoop was called   
    _a_: 'add-and-display-current-project   Go to the last pos. where swoop was called   
    _x_: 'current-project-exclusively       Go to the last pos. where swoop was called   
    _e_: 'treemacs-edit-workspaces          Go to the last pos. where swoop was called   
    _1_: 'treemacs-delete-other-windows     search in all selected buffers    
    _B_: 'treemacs-bookmark                search in all buffers   
    _f_: 'treemacs-find-file               search in all buffers   
    _g_: 'treemacs-find-tag                search in all buffers   
    _r_: 'treemacs-quit                    remove treemacs panel  
    _q_: quit                       
    "
    ("0"     treemacs-select-window)
    ("t"     treemacs)
    ("1"     treemacs-delete-other-windows)
    ("a"     treemacs-add-and-display-current-project)
    ("x"     treemacs-display-current-project-exclusively)
    ("e"     treemacs-edit-workspaces)
    ("B"     treemacs-bookmark)
    ("f"     treemacs-find-file)
    ("g"     treemacs-find-tag)
    ("r"     treemacs-quit)
    ("q"     nil)
  )

  (defhydra hydra-thesaurus ()
    "thesaurus"
    ("a" mw-thesaurus-lookup-at-point)
    ("f" sdcv-search)
    ("q" nil "quit" :color blue)
  )

;;source: https://hungyi.net/posts/hydra-for-evil-mc/
  (defhydra hydra-evil-mc (:color pink
			   :hint nil
			   :pre (evil-mc-pause-cursors))
    "
    ^Match^            ^Line-wise^           ^Manual^
    ^^^^^^-------------------------------------------------------------------------
    _Z_: match all     _J_:   make & go down                    _z_: toggle here
    _m_: make & next   _K_:   make & go up                      _r_: remove last
    _M_: make & prev   _H_:   vertical block                    _R_: remove all
    _n_: skip & next   _gr+_: increase number at each cursor    _p_: pause/resume
    _N_: skip & prev   _gr-_: decrease number at each cursor

    Current pattern: %`evil-mc-pattern

    "
    ("Z"   #'evil-mc-make-all-cursors)
    ("m"   #'evil-mc-make-and-goto-next-match)
    ("M"   #'evil-mc-make-and-goto-prev-match)
    ("n"   #'evil-mc-skip-and-goto-next-match)
    ("N"   #'evil-mc-skip-and-goto-prev-match)
    ("J"   #'evil-mc-make-cursor-move-next-line)
    ("K"   #'evil-mc-make-cursor-move-prev-line)
    ("z"   #'multiple-cursors/evil-mc-toggle-cursor-here)
    ("r"   #'multiple-cursors/evil-mc-undo-cursor)
    ("R"   #'evil-mc-undo-all-cursors)
    ("p"   #'multiple-cursors/evil-mc-toggle-cursors)
    ("H"   evil-mc-make-vertical-cursors)
    ("gr+" evil-mc-inc-num-at-each-cursor) ;; see rectangle-number-lines for an alternative
    ("gr-" evil-mc-dec-num-at-each-cursor)
    ("q"   #'evil-mc-resume-cursors "quit" :color blue)
    ("<escape>" #'evil-mc-resume-cursors "quit" :color blue)
  )


  (defhydra hydra-leader (:exit t)
    "
    Treemacs keybindings
    ^Mark^                                  ^Actions^          
    ^^^^^^^^------------------------------------------------------------------------------
    _n_:    make-frame              
    _TAB_:  yankpad-expand           
    _._:    buffer-menu            
    _d_:    kill-this-buffer       
    _l_:    whitespace-mode      
    _c_:    ey-open-config      
    _w_:    ey-open-current-project     
    _a_:    ey-open-agenda      
    _t_:    hydra-thesaurus/body
    _p_:    hydra-helm-projectile/body  
    _h_:    helm-projectile       
    _qq_:   delete-window         
    _qw_:   kill-buffer-and-window
    _f_:    hydra-evil-mc/body 

    "
    ("n"     make-frame)
    ("TAB"   yankpad-expand)
    ("."     buffer-menu)
    ("d"     kill-this-buffer)
    ("l"     whitespace-mode)  ;; Show invisible characters
    ("c"     ey-open-config )
    ("w"     ey-open-current-project )
    ("a"     hydra-agenda/body)
    ("t"     hydra-thesaurus/body)
    ;; Projectile
    ("p"     hydra-helm-projectile/body)
    ("h"     helm-projectile)
    ("qq"    delete-window)
    ("qw"    kill-buffer-and-window)
    ;; Multiple cursors 
    ("f"     hydra-evil-mc/body)
  ;   ("a"      'org-insert-structure-template)

  )


  (defhydra hydra-helm-projectile ()
    "
    Treemacs keybindings
    ^Mark^                                  ^Actions^          
    ^^^^^^^^------------------------------------------------------------------------------
    _b_:    'helm-projectile-switch-to-buffer     
    _d_:    'helm-projectile-find-dir              
    _f_:    'helm-projectile-find-file           
    _F_:    'helm-projectile-find-file-dwim      
    _h_:    'helm-projectile                   
    _p_:    'helm-projectile-switch-project   
    _r_:    'helm-projectile-recentf          
    _g_:    'helm-projectile-grep             

    "

    ("b"  helm-projectile-switch-to-buffer)
    ("d"  helm-projectile-find-dir)
    ("f"  helm-projectile-find-file)
    ("F"  helm-projectile-find-file-dwim)
    ("h"  helm-projectile)
    ("p"  helm-projectile-switch-project)
    ("r"  helm-projectile-recentf)
    ("g"  helm-projectile-grep)

  )



  (defhydra hydra-agenda ()
    "
    Treemacs keybindings
    ^Mark^                        ^Actions^          
    ^^^^^^^^------------------------------------------------------------------------------
    _t_:  org-todo                   open to-do menu                    
    _a_:  org-agenda	             open agenda          
    _s_:  org-schedule	             set schedule for task          
    _d_:  org-deadline	             set deadline for task          
    _c_:  org-capture	             capture new items
    _i_:  org-clock-in	             clock in to the section you're currently in          
    _o_:  org-clock-out              clock out of whatever you're clocked in to                         
    _g_:   org-clock-goto             jump to whatever headline you are currently clocked in to          
    _r_:  org-refile	             move header to other part of the document 
    _l_:  calendar	             open calendar          
    _v_:  org-columns	             show columns in org-files with the time clocked          
    _z_:  ey-open-agenda             open main agenda file          
    _e_:  org-time-stamp-inactive    activate inactive time stamp
    _f_:  org-set-effort             set effort to complete a task
    "

    ("t"  org-todo)
    ("a"  org-agenda)
    ("s"  org-schedule)
    ("d"  org-deadline)
    ("c"  org-capture)
    ("i"  org-clock-in)
    ("o"  org-clock-out)
    ("g"  org-clock-goto)
    ("r"  org-refile)
    ("l"  calendar)
    ("v"  org-columns)
    ("z"  ey-open-agenda)
    ("e"   org-time-stamp-inactive)
    ("f"   org-set-effort)
    ("q"   #'evil-mc-resume-cursors "quit" :color blue)
    ("<escape>" #'evil-mc-resume-cursors "quit" :color blue)

;; for setting time stamps see this page from the manual:
;; https://orgmode.org/manual/The-date_002ftime-prompt.html

;;Key             Calls                   Action
;;C-c C-x C-i 	org-clock-in            Clock in to the section you're currently in
;;C-c C-x C-o 	org-clock-out           Clock out of whatever you're clocked in to
;;C-c C-x C-x 	org-clock-in-last 	Clock in to the last clocked task
;;C-c C-x C-j 	org-clock-goto          Jump to whatever headline you are currently clocked in to
;;C-c C-x C-q 	org-clock-cancel 	Cancel the current clock (removes all of it's current time)
;;C-c C-x C-d 	org-clock-display 	Display clock times for headlines in current file
;;C-c C-x C-r 	org-clock-report 	Generate a report for clock activity
;;C-c C-x C-z 	org-resolve-clocks 	Resolve any half-open clocks

;; remap
;; org-capture-kill
;; org-capture-refile
;; org-capture-finalize

;;(global-set-key (kbd "<f9> t") 'bh/insert-inactive-timestamp)
;;(global-set-key (kbd "<f9> T") 'bh/toggle-insert-inactive-timestamp)
  )





)

(use-package undo-tree
  :init
  (global-undo-tree-mode 1) ;; to use evil-undo, evil-redo
)

(use-package evil
  :init 
  ;; these parameters are required for evil collection
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  :hook 
  ;; add code folding
  ('prog-mode . #'hs-minor-mode)
  ;; ('c-mode-common-hook   . 'hs-minor-mode)
  ;; ('emacs-lisp-mode-hook . 'hs-minor-mode)
  ;; ('java-mode-hook       . 'hs-minor-mode)
  ;; ('lisp-mode-hook       . 'hs-minor-mode)
  ;; ('perl-mode-hook       . 'hs-minor-mode)
  ;; ('sh-mode-hook         . 'hs-minor-mode)
  :bind
  (
  :map evil-normal-state-map
  ("," . 'hydra-leader/body)
  ("M-." . 'xref-find-definitions)
  :map evil-visual-state-map
  ("," . 'hydra-leader/body)
  )
  :config
  (evil-mode 1)
  ;; allows pasting from the register
  (evil-select-search-module 'evil-search-module 'evil-search)
  (evil-set-undo-system 'undo-tree)
;;  (evil-define-key 'normal 'global "," 'hydra-leader/body)
;;  (evil-define-key 'normal 'global (kbd "SPC") 'hydra-leader/body)

;;   in case I wish to edit folding manually
;;   (setq evil-fold-list
;;         '(((hs-minor-mode)
;;            :open-all hs-show-all 
;;            :close-all hs-hide-all 
;;            :toggle hs-toggle-hiding 
;;            :open hs-show-block 
;;            :open-rec nil 
;;            :close hs-hide-block 
;;            :close-level my-hs-hide-level)
;;           )
;;   )

;;   folding backends available
;;   vdiff-mode
;;   vdiff-3way-mode
;;   hs-minor-mode
;;   hide-ifdef-mode
;;   outline-mode
;;   origami-mode

)




;; add and change delimiters
(use-package evil-surround
 :after evil
 :config
 (global-evil-surround-mode 1)
)

;; jump between delimiters
(use-package evil-matchit 
  :after evil
  :config
 (global-evil-matchit-mode 1)
)

;; comment lines
(use-package evil-commentary 
  :after evil
)

;; improve search
;;(use-package evil-anzu 
;;  :after evil
;;;;  :config
;;  (global-anzu-mode +1)
;;)

;; better way to jump to word
(use-package evil-snipe 
  :after evil
  :config
  (evil-snipe-mode +1)
  ;;(evil-snipe-override-mode +1) ;; this messes finding with multiple cursors in evil-mc
  (add-hook 'magit-mode-hook 'turn-off-evil-snipe-override-mode)
  (setq evil-snipe-scope 'line)
  (setq evil-snipe-repeat-scope 'buffer)
  (setq evil-snipe-spillover-scope 'buffer)
)

;; realign blocks of text
(use-package evil-lion
  :after evil
  :config
  (evil-lion-mode)
)

;; work with blocks of text
(use-package evil-indent-plus 
  :after evil
  :config
  (evil-indent-plus-default-bindings)
)

;; keybindings for evil almost everywhere
(use-package evil-collection
  :after evil
  :straight (evil-collection :type git :flavor melpa :host github :repo "emacs-evil/evil-collection"
              :fork (:host github :files (:defaults "modes" "evil-collection-pkg.el") :repo "nettoyoussef/evil-collection"))
  :custom (evil-collection-setup-minibuffer t)
  :config
  (evil-collection-init)
)

;; makes evil play nicer with org
(use-package evil-org
  :after org evil
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'evil-org-mode-hook
    (lambda ()
     ;; navigation conflicts with evil-lion
     (evil-org-set-key-theme '(textobjects additional))
    )
  )
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)
)

;;use evil-scape instead of my command with C-c 
(use-package evil-exchange
  :after evil
  :config
  (evil-exchange-install)
)

;;use evil-scape instead of my command with C-c 
(use-package evil-escape
  :after evil
  :bind
;  (
  ;;("fd" . evil-escape-key-sequence)
;  )
  :config
  (evil-escape-mode)
  (setq-default evil-escape-key-sequence "fd")
  (setq-default evil-escape-delay 0.1)
)

;; use ["+]griw to substitute word with
;; register "+.  
(use-package evil-replace-with-register 
  :after evil
  :config
  ;; change default key bindings (if you want) HERE
  (setq evil-replace-with-register-key (kbd "gr"))
  (evil-replace-with-register-install)
)

;; invert shift behavior for keyboard on the number line
;; S-1 becomes 1 and 1 becomes !
;; other swaps are available, but these were the most interesting
;;(use-package evil-swap-keys 
;;;;  :after evil
;;  :config
;;  (global-evil-swap-keys-mode)
;;  (add-hook 'prog-mode-hook #'evil-swap-keys-swap-number-row)
;;)

;;; C-c as general purpose escape key sequence.
;;; source: https://www.emacswiki.org/emacs/Evil
;;;
(defun my-esc (prompt)
  "Functionality for escaping generally.  Includes exiting Evil insert state and C-g binding. "
  (cond
   ;; If we're in one of the Evil states that defines [escape] key, return [escape] so as
   ;; Key Lookup will use it.
   ((or (evil-insert-state-p) (evil-normal-state-p) (evil-replace-state-p) (evil-visual-state-p)) [escape])
   ;; This is the best way I could infer for now to have C-c work during evil-read-key.
   ;; Note: As long as I return [escape] in normal-state, I don't need this.
   ;;((eq overriding-terminal-local-map evil-read-key-map) (keyboard-quit) (kbd ""))
   (t (kbd "C-g"))))
(define-key key-translation-map (kbd "C-c") 'my-esc)
;; Works around the fact that Evil uses read-event directly when in operator state, which
;; doesn't use the key-translation-map.
(define-key evil-operator-state-map (kbd "C-c") 'keyboard-quit)
;; Not sure what behavior this changes, but might as well set it, seeing the Elisp manual's
;; documentation of it.
;(set-quit-char "C-c")
; this last line doesn't work - error: 'QUIT must be an ASCI code.'

;; Altering the functioning of q
;; source: https://www.reddit.com/r/spacemacs/comments/6p3w0l/making_q_not_kill_emacs/
;; :q should kill the current buffer rather than quitting emacs entirely
(evil-ex-define-cmd "q" 'kill-this-buffer)
;; Need to type out :quit to close emacs
(evil-ex-define-cmd "quit" 'evil-quit)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (evil))))

;; Display relative numbers
;; source: https://github.com/noctuid/evil-guide
(setq-default display-line-numbers 'visual
              display-line-numbers-widen t
              ;; this is the default
              display-line-numbers-current-absolute t)

(defun noct:relative ()
  (setq-local display-line-numbers 'visual))

(defun noct:absolute ()
  (setq-local display-line-numbers t))

(add-hook 'evil-insert-state-entry-hook #'noct:absolute)
(add-hook 'evil-insert-state-exit-hook #'noct:relative)

(use-package expand-region
  :defer t
  :bind
  (("M-n" . 'er/expand-region))
  :config
  (defun er/add-text-mode-expansions ()
(make-variable-buffer-local 'er/try-expand-list)
(setq er/try-expand-list (append
		    er/try-expand-list
		    '(mark-paragraph
		      mark-page))))

  (add-hook 'text-mode-hook 'er/add-text-mode-expansions)
)

(use-package evil-mc 
  ;; doesnt work well with defer, it doesnt autoload in the correct time  
  ;; :defer 2 
   :bind
   (
    :map evil-mc-cursors-map
    ("m" . nil) 
    ("u" . nil) 
    ("q" . nil) 
    ("s" . nil) 
    ("r" . nil) 
    ("f" . nil) 
    ("l" . nil) 
    ("h" . nil) 
    ("j" . nil) 
    ("k" . nil) 
    ("N" . nil) 
    ("P" . nil) 
    ("n" . nil) 
    ("p" . nil) 
    ("I" . nil) 
    ("A" . nil) 
   )
   :config
   (global-evil-mc-mode  1) ;; enable

  ;; the functions below help to edit several lines in a paragraph
  ;; by making vip + ,fH + edits + ,fR
  ;; source: https://github.com/syl20bnr/spacemacs/issues/2669#issuecomment-273356499
   (defun evil--mc-make-cursor-at-col (startcol _endcol orig-line)
     (move-to-column startcol)
     (unless (= (line-number-at-pos) orig-line)
       (evil-mc-make-cursor-here)
     )
   )

   ;;; During visual selection point has +1 value
   ;; modified from:
   ;; https://github.com/syl20bnr/spacemacs/issues/2669#issuecomment-273356499
   ;; original source: https://github.com/syl20bnr/spacemacs/issues/2669#issuecomment-422022560
   ;; other versions: https://github.com/gabesoft/evil-mc/issues/22#issuecomment-273352904
   (defun evil-mc-make-vertical-cursors (beg end)
     ;;; Because `evil-mc-resume-cursors` produces a cursor,
     ;;; we have to skip a current line here to avoid having +1 cursor
     (interactive (list (region-beginning) (- (region-end) 1)))
     (evil-exit-visual-state)
     (evil-mc-pause-cursors)
     (apply-on-rectangle #'evil--mc-make-cursor-at-col
                         beg end (line-number-at-pos))
     (evil-mc-resume-cursors)
      ;;; Because `evil-mc-resume-cursors` produces a cursor, we need to place it on on the
      ;;; same column as the others
     (move-to-column (evil-mc-column-number 0))
   )
)

  (use-package evil-mc-extras
   :defer t
   :config
   (global-evil-mc-extras-mode  1)
  )

  (use-package iedit 
  )

  ;; this package requires 
  ;; expand region to work well
  (use-package evil-iedit-state 
  )

(use-package all-the-icons
  :defer t
)

;; A more complex, more lazy-loaded config
(use-package solaire-mode
  ;; Ensure solaire-mode is running in all solaire-mode buffers
  :hook (change-major-mode . turn-on-solaire-mode)
  ;; ...if you use auto-revert-mode, this prevents solaire-mode from turning
  ;; itself off every time Emacs reverts the file
  :hook (after-revert . turn-on-solaire-mode)
  ;; To enable solaire-mode unconditionally for certain modes:
  :hook (ediff-prepare-buffer . solaire-mode)
  ;; Highlight the minibuffer when it is activated:
  :hook (minibuffer-setup . solaire-mode-in-minibuffer)
  :config
  ;; The bright and dark background colors are automatically swapped the first 
  ;; time solaire-mode is activated. Namely, the backgrounds of the `default` and
  ;; `solaire-default-face` faces are swapped. This is done because the colors 
  ;; are usually the wrong way around. If you don't want this, you can disable it:
  ;; basically, this reverts what is bright and what is dark
  ;;(setq solaire-mode-auto-swap-bg nil)

  (solaire-global-mode +1)
)

(use-package doom-themes 
  :config
  (load-theme 'doom-gruvbox t)
  ;;(load-theme 'doom-tomorrow-night t)
  (setq doom-themes-enable-bold t)    ; if nil, bold is universally disabled
  (setq doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (doom-themes-org-config)
)

;;(use-package ewal
;;  :init (setq ewal-use-built-in-always-p nil
;;              ewal-use-built-in-on-failure-p t
;;              ewal-built-in-palette "sexy-material"))
;;
;;(use-package ewal-spacemacs-themes
;;  :init (progn
;;          (setq spacemacs-theme-underline-parens t
;;                my:rice:font (font-spec
;;                              :family "Source Code Pro"
;;                              :weight 'semi-bold
;;                              :size 11.0))
;;          (show-paren-mode +1)
;;          (global-hl-line-mode)
;;          (set-frame-font my:rice:font nil t)
;;          (add-to-list  'default-frame-alist
;;                        `(font . ,(font-xlfd-name my:rice:font))))
;;  :config (progn
;;            (load-theme 'ewal-spacemacs-modern t)
;;            (enable-theme 'ewal-spacemacs-modern)))
;;(use-package ewal-evil-cursors
;;  :after (ewal-spacemacs-themes)
;;  :config (ewal-evil-cursors-get-colors
;;           :apply t :spaceline t))
;;(use-package spaceline
;;  :after (ewal-evil-cursors winum)
;;  :init (setq powerline-default-separator nil)
;;  :config (spaceline-spacemacs-theme))

(use-package rainbow-delimiters
  :config
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
 )

(use-package highlight-indent-guides 
  :defer t
  :config
  (add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'org-mode-hook 'highlight-indent-guides-mode)
  (setq highlight-indent-guides-method 'character) ;; highlights indentation with lines
 )

(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; Or use this
;; Use `window-setup-hook' if the right segment is displayed incorrectly
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode))

;; Enable and install helm
(use-package helm
  :bind
  (("C-x b"    . helm-mini)
   ("M-x"      . helm-M-x)
   ("C-x C-f"  . helm-find-files)
   ("C-h c"    . helm-apropos)
;;   ("C-:"      . helm-lisp-completion-at-point-company)
   :map helm-find-files-map
   ("C-k"      . helm-find-files-up-one-level))
  :config
  (helm-mode 1)
  (setq helm-autoresize-mode t)
  (setq helm-buffer-max-length 40)
  (setq helm-buffers-fuzzy-matching t
        helm-recentf-fuzzy-match    t)
  (setq helm-apropos-fuzzy-match t)
  (setq helm-split-window-inside-p t)

;; How to avoid helm to split windows? See below where the behavior started
;;source: https://github.com/emacs-helm/helm/issues/1860
;;source: https://www.reddit.com/r/emacs/comments/bbqc67/helmprojectile_trouble_with_opening_multiple/

;;  (define-key helm-map (kbd "S-SPC") 'helm-toggle-visible-mark)
;; :map helm-map
;;([tab] . helm-next-line)
;;([backtab] . helm-previous-line) 
;;(define-key helm-map (kbd "<tab>")    'helm-execute-persistent-action)
;;(define-key helm-map (kbd "<backtab>") 'helm-select-action)
)

;; Enable and install projectile
(use-package projectile
 :defer t
 :bind
 (:map projectile-mode-map
 ("s-p" . projectile-command-map))
 :config
 (projectile-global-mode)
 (setq projectile-switch-project-action 'helm-projectile) ;; requires helm-projectile
)

(use-package helm-projectile
;;  :bind
;;  (("C-S-P" . helm-projectile-switch-project)
;;   :map evil-normal-state-map
;;   ("C-p" . helm-projectile))
  :defer t
  :config 
  (helm-projectile-on)
)

(use-package helm-tramp
  :defer t
 )

(use-package deadgrep
  :commands (deadgrep)
;;  :general (:keymaps 'deadgrep-mode-map "C-c C-w" #'deadgrep-edit-mode)

 ;; :preface
 ;; (defun config-editing--deadgrep-requery ()
 ;;   (interactive)
 ;;   (let ((button (save-excursion
 ;;                   (goto-char (point-min))
 ;;                   (forward-button 1))))
 ;;     (button-activate button)))
 ;; :general (:states 'normal :keymaps 'deadgrep-mode-map "c" #'config-editing--deadgrep-requery)

 ;; :preface
 ;; (defun config-editing--on-enter-deadgrep-edit-mode (&rest _)
 ;;   (message "Entering edit mode. Changes will be made to underlying files as you edit."))
 ;; :config
 ;; (advice-add #'deadgrep-edit-mode :after #'config-editing--on-enter-deadgrep-edit-mode)

 ;; :preface
 ;; (defun config-editing--on-exit-deadgrep-edit-mode (&rest _)
 ;;   (when (derived-mode-p 'deadgrep-edit-mode)
 ;;     (message "Exiting edit mode.")))
 ;; :config
 ;; (advice-add #'deadgrep-mode :before #'config-editing--on-exit-deadgrep-edit-mode)

 ;; :preface
 ;; (defun deadgrep-from-ivy ()
 ;;   (interactive)
 ;;   (ivy-exit-with-action
 ;;    (lambda (&rest _)
 ;;      (let ((deadgrep--search-type 'regexp))
 ;;        (deadgrep (replace-regexp-in-string (rx (+ space)) ".*?" ivy-text))))))
 ;; :init
 ;; (general-define-key :keymaps 'counsel-ag-map "C-c C-e" #'deadgrep-from-ivy))
)

;; repo
;; https://github.com/emacs-helm/helm-recoll
(use-package helm-recoll
  :commands helm-recoll
  :init (setq helm-recoll-directories
	      '(("notes"  . "~/.recoll/notes")
		("zotero" . "~/.recoll/zotero")
               )
        )
)

(use-package company 
 :config
 (add-hook 'after-init-hook 'global-company-mode)
)

(use-package company-statistics
 :defer t
 :config
 (company-statistics-mode)
)

(use-package ess 
 ;;:bind
 ;;(
  ;; add some basic evil functionality on help buffers
  ;;:map  ess-r-help-mode-map 
  ;;("h" . 'evil-backward-char)
  ;;("l" . 'evil-forward-char)
  ;;("j" . 'evil-next-line)
  ;;("k" . 'evil-previous-line)
  ;;("H" . #'ess-display-help-on-object)
  ;;("I" . #'ess-display-package-index)
  ;;("L" . #'ess-eval-line-visibly-and-step)
  ;;("v" . 'evil-visual-char)
  ;;("V" . 'evil-visual-line) 
  ;;("y" . 'evil-yank)
  ;;("Y" . 'evil-yank-line)
  ;;("T" . #'ess-display-vignettes)
 ;;)
 :defer t
 :init 
 ;;(add-hook 'ess-mode-hook (lambda () (local-set-key "\t" 'self-insert-command)))
 (add-hook 'ess-mode-hook 
   (lambda ()  
     (define-key ess-r-help-mode-map "h" 'evil-backward-char)
     (define-key ess-r-help-mode-map "l" 'evil-forward-char)
     (define-key ess-r-help-mode-map "j" 'evil-next-line)
     (define-key ess-r-help-mode-map "k" 'evil-previous-line)
     (define-key ess-r-help-mode-map "H" #'ess-display-help-on-object)
     (define-key ess-r-help-mode-map "I" #'ess-display-package-index)
     (define-key ess-r-help-mode-map "L" #'ess-eval-line-visibly-and-step)
     (define-key ess-r-help-mode-map "v" 'evil-visual-char)
     (define-key ess-r-help-mode-map "V" 'evil-visual-line)
     (define-key ess-r-help-mode-map "y" 'evil-yank)
     (define-key ess-r-help-mode-map "Y" 'evil-yank-line)
     (define-key ess-r-help-mode-map "T" #'ess-display-vignettes)
     (define-key ess-r-help-mode-map "\C-w" #'evil-window-next)
     (define-key ess-r-help-mode-map "gg" 'evil-goto-first-line)
     (define-key ess-r-help-mode-map "G"  'evil-goto-line)
   )
)

  ;; disable the fancy comments feature
  ;; with fancy comments, comments are aligned
  ;; accordingly to the number of # in the line
  ;; ### - beginning of the line
  ;; ## - to the current block of indentation
  ;; # - aligned to the right, 40th column by default
  ;; the value 40th can be changed on the variable
  ;; comment-column
  ;; must be set before initialization,
  ;; see
  ;; https://stackoverflow.com/questions/780796/emacs-ess-mode-tabbing-for-comment-region
  ;; https://stackoverflow.com/a/53458839/7233796
  (setq ess-indent-with-fancy-comments nil)

  ;; remove underible mappings
  ;;(unbind-key "h" ess-r-help-mode-map)
  ;;(unbind-key "l" ess-r-help-mode-map)
  ;;(unbind-key "k" ess-r-help-mode-map) 
  ;;(unbind-key "v" ess-r-help-mode-map)

 :config
 ;;(ess-toggle-underscore nil)
 (setq ess-eval-visibly 'nowait)

  ;; Layout style / window configuration
  ;; source: [[https://ess.r-project.org/Manual/ess.html#Controlling-buffer-display]]
  ;; The following snippet configures the layout of ESS the same way that Rstudio does:    
  (setq display-buffer-alist
        `(("*R Dired"
           (display-buffer-reuse-window display-buffer-in-side-window)
           (side . right)
           (slot . -1)
           (window-width . 0.33)
           (inhibit-same-window . t)
           (reusable-frames . nil))
          ("*R"
           (display-buffer-reuse-window display-buffer-at-bottom)
           (window-width . 0.33)
           (inhibit-same-window . t)
           (reusable-frames . nil)
           (dedicated . t)
          )
          ("*Help"
           (display-buffer-reuse-window display-buffer-in-side-window)
           (side . right)
           (slot . 1)
           (window-width . 0.33)
           (reusable-frames . nil))
         )
  )
  ;; makes emacs scroll down automatically to the end of buffer
  (setq comint-scroll-to-bottom-on-input t)
  (setq comint-scroll-to-bottom-on-output t)
  (setq comint-move-point-for-output t)

  
  ;; The snippet below start up the inferior process and the source code in different frames
  ;;(setq display-buffer-alist
  ;;      '(("*R"
  ;;         (display-buffer-reuse-window display-buffer-pop-up-frame)
  ;;         (reusable-frames . 0))))


)

;; (ess :variables
;;     ess-r-backend 'lsp
;;     ess-style 'RStudio
;;     ess-use-flymake nil
;;     ess-assign-key "\M--")

;;source: https://stat.ethz.ch/pipermail/ess-help/2017-April/012252.html
;; strange error: symbol value as variable is void: ess-r-customize-alist
;;(defun R-docker ()
;;  (interactive)
;;  (let ((ess-r-customize-alist
;;         (append ess-r-customize-alist
;;                 '((inferior-ess-program . "/docker:root@docker_r_r_temp_1:/home/eliasy/"))))
;;        (ess-R-readline t))
;;    (R))
;;)

;(use-package ess-R-data-view 
;; :defer t
;)

(use-package ess-view-data 
;; :defer t
)

(use-package aggressive-indent
  :config
  ;;(add-hook 'ess-mode-hook #'aggressive-indent-mode)
  ;;(add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)
  (add-hook 'prog-mode-hook #'aggressive-indent-mode) ;; set for all programing languages
)

(defvar untabify-var)
(make-variable-buffer-local 'untabify-var) ;; this makes the variable buffer-local 

(defun toggle-untabify()
   "Change the current buffer to an untabified buffer"
    (if untabify-var (setq 'untabify-var nil) (setq 'untabify-var t))
)

(defun prog-mode-untabify ()
  "Untabify and remove trailing whitespace if untabify-var is true"
  (if untabify-var
      (save-excursion
        (delete-trailing-whitespace)
        (untabify (point-min) (point-max))
      )
  )
)

(add-hook 'prog-mode-hook 
 '(lambda()
    (setq-default indent-tabs-mode nil) ;; never use tabs in prog mode
    (setq backward-delete-char-untabify-method 'hungry) ;; never delete one space of a tab at a tab, delete a tab whole
    (setq untabify-var t) ;; this sets the buffer to remove trailling whitespace and tabs
 )
)  
(add-hook 'before-save-hook #'prog-mode-untabify) ;; change tabs to spaces and removes trailling whitespace

(add-hook 'prog-mode-hook 
  '(lambda () (column-delimiter 80))
)

;; emacs-lsp main package
(use-package lsp-mode
  :defer t
  :bind  
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  ;; (("s-l" . lsp-keymap-prefix))
;;     :hook 
;;     ;;  ;; replace XXX-mode with concrete major-mode(e. g. python-mode)
;;     (
;;      (R-mode . lsp)
;;      (ess-r-mode . lsp)
;;      (python-mode . lsp)
;;      ;; if you want which-key integration
;;      (lsp-mode . lsp-enable-which-key-integration)
;;      )
;;     ;; see also the spacemacs config with ess + lsp
;;     ;; https://develop.spacemacs.org/layers/+lang/ess/README.html
;;     ;; (add-hook 'R-mode-hook #'lsp-R-enable)
;;    :commands lsp
    :config 
    ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
    (setq lsp-keymap-prefix "C-l")


    ;; https://www.reddit.com/r/spacemacs/comments/alleyn/ess_completion_without_loading_into_r/
    (lsp-register-client
     (make-lsp-client 
      :new-connection (lsp-stdio-connection '("R" "--slave" "-e" "languageserver::run()"))
      :major-modes '(ess-r-mode)
      :remote? t
      :server-id 'lsp-R))

    ;; (lsp-register-client
    ;;  (make-lsp-client
    ;;   :new-connection (lsp-tramp-connection (lambda () (cons "/home/jwh/bin/ccls" ccls-args)))
    ;;   :major-modes '(ess-r-mode)
    ;;   :server-id 'ccls-remote
    ;;   :multi-root nil
    ;;   :remote? t
    ;;   :notification-handlers
    ;;   (lsp-ht ("$ccls/publishSkippedRanges" #'ccls--publish-skipped-ranges)
    ;;    ("$ccls/publishSemanticHighlight" #'ccls--publish-semantic-highlight))
    ;;   :initialization-options (lambda () ccls-initialization-options)
    ;;   :library-folders-fn nil))


    ;; increase Emacs cache for garbage collection
    ;; The default setting is too low for lsp-mode's 
    ;; needs due to the fact that client/server communication 
    ;; generates a lot of memory/garbage. You have two options:
    ;; (setq gc-cons-threshold 100000000)

    ;; Increase the amount of data which Emacs reads from the 
    ;; process. Again the emacs default is too low 4k 
    ;; considering that the some of the language server 
    ;; responses are in 800k - 3M range.
    (setq read-process-output-max (* 1024 1024)) ;; 1mb

    ;; use company-capf as the completion provider
    (setq lsp-completion-provider :capf)

    ;; Optional: fine-tune lsp-idle-delay. This variable 
    ;; determines how often lsp-mode will refresh the 
    ;; highlights, lenses, links, etc while you type.
    (setq lsp-idle-delay 0.100)

    ;; disable other UI options
    ;; (setq lsp-keep-workspace-alive nil)
    ;; (setq lsp-signature-auto-activate nil)
    ;; (setq lsp-modeline-code-actions-enable nil)
    ;; (setq lsp-modeline-diagnostics-enable nil)
    ;; (setq lsp-enable-file-watchers nil)
    ;; (setq lsp-enable-folding nil)
    ;; (setq lsp-enable-semantic-highlighting nil)
    ;; (setq lsp-enable-symbol-highlighting nil)
    ;; (setq lsp-enable-text-document-color nil)
    ;; (setq lsp-enable-indentation nil)
    ;; (setq lsp-enable-on-type-formatting nil)

    )

;; optionally
(use-package lsp-ui
  :defer t
  :commands lsp-ui-mode
  )

;; optionally if you want to use debugger
(use-package dap-mode
  :defer t
  )

;; if you are helm user
(use-package helm-lsp 
  :defer t
  :commands helm-lsp-workspace-symbol
  )
;; if you are ivy user
;;(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

;; tremacs compatibility
;;(use-package lsp-treemacs 
;;;;  :commands lsp-treemacs-errors-list
;;  )
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

(use-package helm-company
 :defer t
 :bind
 (
  ("C-:" . 'helm-company)
 )
)

(use-package poly-markdown 
 :defer t
 :config

 ;; MARKDOWN
 (add-to-list 'auto-mode-alist '("\\.md" . poly-markdown-mode))

 ;; R modes
 (add-to-list 'auto-mode-alist '("\\.Snw" . poly-noweb+r-mode))
 (add-to-list 'auto-mode-alist '("\\.Rnw" . poly-noweb+r-mode))
 (add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode))

)

(use-package poly-R
 :defer t
)

(use-package flycheck
  :defer t
  :config (global-flycheck-mode)
)

(use-package helm-ag
 :defer t
 :config
 ;; configuration to use rg as main search engine
 (custom-set-variables
  '(helm-ag-base-command "rg --vimgrep --no-heading --smart-case")
  `(helm-ag-success-exit-status '(0 2)))
)

(use-package helm-swoop 
 :defer t
 :bind
 ;; Move up and down like isearch
 (
;; Change the keybinds to whatever you like :D
;;     ("M-i"       . 'helm-swoop)
;;     ("M-I"       . 'helm-swoop-back-to-last-point)
;;     ("C-c M-i"   . 'helm-multi-swoop)
;;     ("C-x M-i"   . 'helm-multi-swoop-all)
  :map helm-swoop-map
  ("C-p"     . 'helm-previous-line)
  ("C-n"     . 'helm-next-line)
  ("M-m"     . 'helm-multi-swoop-current-mode-from-helm-swoop)
  :map helm-multi-swoop-map
  ("C-p"     . 'helm-previous-line)
  ("C-n"     . 'helm-next-line)
  :map helm-swoop--basic-map
  ("C-s"     . 'helm-swoop-edit)
  :map helm-multi-swoop--basic-map
  ("C-s"     . 'helm-multi-swoop-edit)
  :map helm-swoop-edit-map
  ("C-s"     . 'helm-swoop--edit-complete)
  ("C-g"     . 'helm-swoop--edit-cancel)
  :map helm-multi-swoop-edit-map
  ("C-s"     . 'helm-multi-swoop--edit-complete)
  ("C-g"     . 'helm-multi-swoop--edit-cancel)
 )
 :config
 ;; From helm-swoop to helm-multi-swoop-all
 ;;(define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop)
 ;; When doing evil-search, hand the word over to helm-swoop
 ;; (define-key evil-motion-state-map (kbd "M-i") 'helm-swoop-from-evil-search)

 ;; Instead of helm-multi-swoop-all, you can also use helm-multi-swoop-current-mode
 ;(define-key helm-swoop-map (kbd "M-m") 'helm-multi-swoop-current-mode-from-helm-swoop)

 ;; Save buffer when helm-multi-swoop-edit complete
 (setq helm-multi-swoop-edit-save t)

 ;; If this value is t, split window inside the current window
 (setq helm-swoop-split-with-multiple-windows t)

 ;; Split direcion. 'split-window-vertically or 'split-window-horizontally
 (setq helm-swoop-split-direction 'split-window-horizontally)

 ;; If nil, you can slightly boost invoke speed in exchange for text color
 (setq helm-swoop-speed-or-color nil)

 ;; ;; Go to the opposite side of line from the end or beginning of line
 (setq helm-swoop-move-to-line-cycle t)

 ;; Optional face for line numbers
 ;; Face name is `helm-swoop-line-number-face`
 (setq helm-swoop-use-line-number-face t)

 ;; If you prefer fuzzy matching
 (setq helm-swoop-use-fuzzy-match t)

)

;; Enable and install magit
(use-package dumb-jump 
  :hook
  (('xref-backend-functions . #'dumb-jump-xref-activate))
  :defer t
  :config 
  ;;(setq dumb-jump-prefer-searcher 'rg)
  ;;(dumb-jump-mode)
)

;; Enable and install magit
(use-package magit
  :defer t
)

(use-package ivy
  :defer t
)

(use-package ranger 
  :defer t
  :config

  ;; panel configuration
  (setq ranger-parent-depth 1)
  (setq ranger-width-preview 0.5)
  (setq ranger-width-parents 0.12)
  (setq ranger-max-parent-width 0.12)

  ;; show hidden files
  (setq ranger-show-hidden t)

  ;; set ranger for previewing files
  (setq ranger-preview-file t)

  ;; maximum size of files for preview - in mb
  (setq ranger-max-preview-size 10)

  ;; dont show binary files
  (setq ranger-dont-show-binary t)
)

;(defun suppress-messages (old-fun &rest args)
;  (cl-flet ((silence (&rest args1) (ignore)))
;    (advice-add 'message :around #'silence)
;    (unwind-protect
;         (apply old-fun args)
;      (advice-remove 'message #'silence))))
;
;
;(advice-add 'org-latex-preview :around #'suppress-messages)
;
;(defun who-called-me? (old-fun format &rest args)
;  (let ((trace nil) (n 1) (frame nil))
;      (while (setf frame (backtrace-frame n))
;        (setf n     (1+ n) 
;              trace (cons (cadr frame) trace)) )
;      (apply old-fun (concat "<<%S>>\n" format) (cons trace args))))
;
;(advice-add 'message :around #'who-called-me?)
;

(use-package yasnippet
  :defer t
  :config
  (yas-global-mode 1)
  (yas-reload-all)
 )

;;teste
(use-package yankpad 
  :straight (yankpad :type git :host github :repo "Kungsgeten/yankpad"
              :fork (:host github :repo "nettoyoussef/yankpad"))
  :defer 5 
  :init
  (setq yankpad-file "~/.emacs.d/snippets/yankpad.org")
  :demand t
  ;; really necessary to have demand t above, so you dont need to execute a function for the package to load first
  ;; see more details at
  ;; https://github.com/Kungsgeten/yankpad/issues/20
  :config
  (bind-key "<f7>" 'yankpad-map)
  ;;(bind-key "<C-\t>" 'yankpad-expand)
  ;;(global-set-key (kbd "<C-tab>") 'yankpad-expand)
  ;;(global-set-key (kbd "<C-z>") 'yankpad-expand)
  ;;(global-yankpad-expand-mode 1)
)
  
;;(use-package smart-tab
;;;;  :init
;;  :config
;;  (setq smart-tab-using-hippie-expand t)
;;  (add-to-list 'hippie-expand-try-functions-list #'yankpad-expand)
;;  (global-smart-tab-mode 1)
;;  )

(use-package writegood-mode 
  :defer t
;;  :init
 )

;; requires languagetool
;; sudo pacman -S languagetool
      
(use-package langtool
  :init
  (setq langtool-java-classpath
        "/usr/share/languagetool:/usr/share/java/languagetool/*")

  ;; do autocorrect automatically after entering a text file
  (dolist (hook '(text-mode-hook))
      (add-hook hook (lambda () (flyspell-mode 1))))
  :defer t
  :config
  (setq langtool-default-language "en-US")
  (add-hook 'markdown-mode-hook
            (lambda () 
               (add-hook 'after-save-hook 'langtool-check nil 'make-it-local)))
 )

;; requires sdcv installed to read star file
;; yay -S sdcv
;; Tell emacs where is your personal elisp lib dir
;;(add-to-list 'load-path "~/.emacs.d/lisp/")
(load "~/.emacs.d/lisp/sdcv-mode")

(use-package which-key 
  :config
  (which-key-mode)
)

;; was not able to make it work if a default use package declaration
;; an error would appear:
;; search-failed ",tkk:'"
;; the code from the page below seems to solve the issue
;; https://github.com/atykhonov/google-translate/issues/137
(use-package google-translate
  :init
       (require 'google-translate)

  :functions (my-google-translate-at-point google-translate--search-tkk)
  :custom
  (google-translate-backend-method 'curl)
  :config
  (setq google-translate-default-source-language "en")
  (setq google-translate-default-target-language "pt")
  (defun google-translate--search-tkk () "Search TKK." (list 430675 2721866130))
)

;; there is a script for finding the current tkk number
;; on the link below
;; https://github.com/atykhonov/google-translate/issues/52
;;#!/bin/sh
;;
;;tkk_string=`curl --silent -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" -L http://translate.google.com/ | sed 's/, */\n /g' | grep "tkk" | head -1`
;;
;;first_number=`echo ${tkk_string} | cut -d"'" -f2 | cut -d"." -f1`
;;second_number=`echo ${tkk_string} | cut -d"'" -f2 | cut -d"." -f2`
;;
;;echo '(defun google-translate--search-tkk () "Search TKK." (list '"${first_number}"' '"${second_number}"'))'

(use-package vterm
    :straight t)

(defvar ey--tangle-on-saving)
(make-variable-buffer-local 'ey--tangle-on-saving) ;; this makes the variable buffer-local 

(defun ey--toggle-tangle-on-saving()
   "Change the current buffer to a tangle on saving buffer"
    (if ey--tangle-on-saving (setq 'ey--tangle-on-saving nil) (setq 'ey--tangle-on-saving t))
)

(defun ey--tangle-on-saving ()
  "Export block codes on saving"
  (if ey--tangle-on-saving
        (org-babel-tangle)
  )
)

(add-hook 'after-save-hook (lambda ()(ey--tangle-on-saving)))
