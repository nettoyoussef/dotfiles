
  ;; Some helper functions for agenda views
  (defun gs/org-agenda-prefix-string ()
    "Format"
    (let ((path (org-format-outline-path (org-get-outline-path))) ; "breadcrumb" path
  	(stuck (gs/org-agenda-project-warning))) ; warning for stuck projects
         (if (> (length path) 0)
  	   (concat stuck ; add stuck warning
  		   " [" path "]") ; add "breadcrumb"
  	 stuck)))
  
  (defun gs/org-agenda-add-location-string ()
    "Gets the value of the LOCATION property"
    (let ((loc (org-entry-get (point) "LOCATION")))
      (if (> (length loc) 0)
  	(concat "{" loc "} ")
        "")))

  (defun gs/select-with-tag-function (select-fun-p)
    (save-restriction
      (widen)
      (let ((next-headline
  	   (save-excursion (or (outline-next-heading)
  			       (point-max)))))
        (if (funcall select-fun-p) nil next-headline))))

  ;; Agenda filters for the next blocks
  ;; mainly from the bh/helper-functions

  ;;   (defun gs/is-project-p ()
  ;;     "A task with a 'PROJ' keyword"
  ;;     (member (nth 2 (org-heading-components)) '("PROJ")))

  ;; I prefer the BH approach for projects
  ;; To avoid refactoring the whole code I just
  ;; swapped functions   
  (defun gs/is-project-p ()
    "Any task with a todo keyword subtask."
    (save-restriction
      (widen)
      (let ((has-subtask)
            (subtree-end (save-excursion (org-end-of-subtree t)))
            (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
        (save-excursion
          (forward-line 1)
          (while (and (not has-subtask)
                      (< (point) subtree-end)
                      (re-search-forward "^\*+ " subtree-end t))
            (when (member (org-get-todo-state) org-todo-keywords-1)
              (setq has-subtask t))))
        (and is-a-task has-subtask))))

  (defun bh/is-project-p ()
    "Any task with a todo keyword subtask."
    (save-restriction
      (widen)
      (let ((has-subtask)
            (subtree-end (save-excursion (org-end-of-subtree t)))
            (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
        (save-excursion
          (forward-line 1)
          (while (and (not has-subtask)
                      (< (point) subtree-end)
                      (re-search-forward "^\*+ " subtree-end t))
            (when (member (org-get-todo-state) org-todo-keywords-1)
              (setq has-subtask t))))
        (and is-a-task has-subtask))))


  (defun gs/find-project-task ()
    "Any task with a todo keyword that is in a project subtree"
    (save-restriction
      (widen)
      (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
        (while (org-up-heading-safe)
  	(when (member (nth 2 (org-heading-components)) '("PROJ"))
  	  (setq parent-task (point))))
        (goto-char parent-task)
        parent-task)))
  
  (defun gs/is-project-subtree-p ()
    "Any task with a todo keyword that is in a project subtree.
  Callers of this function already widen the buffer view."
    (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
                                (point))))
      (save-excursion
        (gs/find-project-task)
        (if (equal (point) task)
            nil t))))
  
  (defun bh/find-project-task ()
    "Move point to the parent (project) task if any."
    (save-restriction
      (widen)
      (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
        (while (org-up-heading-safe)
          (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
            (setq parent-task (point))))
        (goto-char parent-task)
        parent-task)))
  
  (defun bh/is-project-subtree-p ()
    "Any task with a todo keyword that is in a project subtree.
  Callers of this function already widen the buffer view."
    (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
                                (point))))
      (save-excursion
        (bh/find-project-task)
        (if (equal (point) task)
            nil
          t))))



  ;;;; Agenda functions used in the custom agenda definitions 

  (defun gs/select-projects ()
    "Selects tasks which are project headers"
    (gs/select-with-tag-function #'gs/is-project-p))
  
  (defun gs/select-project-tasks ()
    "Skips tags which belong to projects (and is not a project itself)"
    (gs/select-with-tag-function
     #'(lambda () (and
  		 (not (gs/is-project-p))
  		 (gs/is-project-subtree-p)))))
  
  (defun gs/select-standalone-tasks ()
    "Skips tags which belong to projects. Is neither a project, nor does it blong to a project"
    (gs/select-with-tag-function
     #'(lambda () (and
  		 (not (gs/is-project-p))
  		 (not (gs/is-project-subtree-p))))))
  
  (defun gs/select-projects-and-standalone-tasks ()
    "Skips tags which are not projects"
    (gs/select-with-tag-function
     #'(lambda () (or
  		 (gs/is-project-p)
  		 (gs/is-project-subtree-p)))))
  
  (defun gs/org-agenda-project-warning ()
    "Is a project stuck or waiting. If the project is not stuck,
  show nothing. However, if it is stuck and waiting on something,
  show this warning instead."
    (if (gs/org-agenda-project-is-stuck)
      (if (gs/org-agenda-project-is-waiting) " !W" " !S") ""))
  
  (defun gs/org-agenda-project-is-stuck ()
    "Is a project stuck"
    (if (gs/is-project-p) ; first, check that it's a project
        (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
  	     (has-next))
  	(save-excursion
  	  (forward-line 1)
  	  (while (and (not has-next)
  		      (< (point) subtree-end)
  		      (re-search-forward "^\\*+ NEXT " subtree-end t))
  	    (unless (member "WAITING" (org-get-tags-at))
  	      (setq has-next t))))
  	(if has-next nil t)) ; signify that this project is stuck
      nil)) ; if it's not a project, return an empty string
  
  (defun gs/org-agenda-project-is-waiting ()
    "Is a project stuck"
    (if (gs/is-project-p) ; first, check that it's a project
        (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
  	(save-excursion
  	  (re-search-forward "^\\*+ WAITING" subtree-end t)))
      nil)) ; if it's not a project, return an empty string

 ;;;; Agenda Post-processing

 ;; Highlight the "!!" for stuck projects (for emphasis)
 (defun gs/org-agenda-project-highlight-warning ()
   (save-excursion
     (goto-char (point-min))
     (while (re-search-forward "!W" nil t)
       (progn
 	(add-face-text-property
 	 (match-beginning 0) (match-end 0)
 	 '(bold :foreground "orange"))
 	))
     (goto-char (point-min))
     (while (re-search-forward "!S" nil t)
       (progn
 	(add-face-text-property
 	 (match-beginning 0) (match-end 0)
 	 '(bold :foreground "white" :background "red"))
 	))
     (goto-char (point-min))
     (while (re-search-forward ":OPT:" nil t)
       (progn
 	(put-text-property
 	 (+ 14 (point-at-bol)) (match-end 0)
 	 'face 'font-lock-comment-face)  ; also 'org-time-grid
 	))
     (goto-char (point-min))
     (while (re-search-forward ":TENT:" nil t)
       (progn
 	(put-text-property
 	 (+ 14 (point-at-bol)) (match-end 0)
 	 'face 'font-lock-comment-face)
 	))
     ))

  ;;;; Agenda Navigation
  
  ;; Search for a "=" and go to the next line
  (defun gs/org-agenda-next-section ()
    "Go to the next section in an org agenda buffer."
    (interactive)
    (if (search-forward "===" nil t 1)
        (forward-line 1)
      (goto-char (point-max)))
    (beginning-of-line))
  
  ;; Search for a "=" and go to the previous line
  (defun gs/org-agenda-prev-section ()
    "Go to the next section in an org agenda buffer."
    (interactive)
    (forward-line -2)
    (if (search-forward "===" nil t -1)
        (forward-line 1)
      (goto-char (point-min))))
  
  ;; Remove empty agenda blocks
  (defun gs/remove-agenda-regions ()
    (save-excursion
      (goto-char (point-min))
      (let ((region-large t))
        (while (and (< (point) (point-max)) region-large)
  	(set-mark (point))
  	(gs/org-agenda-next-section)
  	(if (< (- (region-end) (region-beginning)) 5) (setq region-large nil)
  	  (if (< (count-lines (region-beginning) (region-end)) 4)
  	      (delete-region (region-beginning) (region-end)))
  	  )))))

 ;; == clocking Functions ==
 (require 'org-clock)

  ;; function for first clock on the day
  (defun bh/punch-in (arg)
   "Start continuous clocking and set the default task to the
selected task.  If no task is selected set the Organization task
as the default task."
   (interactive "p")
   (setq bh/keep-clock-running t)
   (if (equal major-mode 'org-agenda-mode)
       ;;
       ;; We're in the agenda
       ;;
       (let* ((marker (org-get-at-bol 'org-hd-marker))
              (tags (org-with-point-at marker (org-get-tags-at))))
         (if (and (eq arg 4) tags)
             (org-agenda-clock-in '(16))
           (bh/clock-in-organization-task-as-default)))
     ;;
     ;; We are not in the agenda
     ;;
     (save-restriction
       (widen)
       ; Find the tags on the current task
       (if (and (equal major-mode 'org-mode) (not (org-before-first-heading-p)) (eq arg 4))
           (org-clock-in '(16))
         (bh/clock-in-organization-task-as-default)))))


  ;; function for clocking-out the day
  (defun bh/punch-out ()
    (interactive)
    (setq bh/keep-clock-running nil)
    (when (org-clock-is-active)
      (org-clock-out))
    (org-agenda-remove-restriction-lock))

  ;; acessory functions for punching in and out
  (defun bh/clock-in-organization-task-as-default ()
    (interactive)
    (org-with-point-at (org-id-find bh/organization-task-id 'marker)
      (org-clock-in '(16))))

 
  ;; If not a project, clocking-in changes TODO to NEXT
  (defun bh/clock-in-to-next (kw)
    "Switch a task from TODO to NEXT when clocking in.
  Skips capture tasks, projects, and subprojects.
  Switch projects and subprojects from NEXT back to TODO"
    (when (not (and (boundp 'org-capture-mode) org-capture-mode))
      (cond
       ((and (member (org-get-todo-state) (list "TODO"))
             (not (bh/is-project-p)))
        "NEXT")
       ((and (member (org-get-todo-state) (list "NEXT"))
             (bh/is-project-p))
        "TODO"))))
 
 
  ;; === Custom Clocktable ===
  (require 'org-clock)
  (defun gjs-org-clocktable-filter-empty-tables (ipos tables params)
    "Removes all empty tables before printing the clocktable"
    (org-clocktable-write-default ipos
  				(seq-filter
  				 (lambda (tbl)
  				   (not (null (nth 2 tbl))))
  				 tables)
  				params)
  )
 
  (defun org-dblock-write:gjs-daily-clocktable (params)
    "Custom clocktable command for my daily log"
    (let ((local-params params)
  	(date-str
  	 (if (plist-get params ':date)
  	 (substring
  		   (plist-get params ':date)
  		   1 11)))
  	)
      (plist-put params ':block date-str)
      (plist-put params ':formatter 'gjs-org-clocktable-filter-empty-tables)
      (plist-put params ':scope 'agenda)
      (org-dblock-write:clocktable params)
      )
  )

  ;; Refile settings
  ;; Exclude DONE state tasks from refile targets
  (defun bh/verify-refile-target ()
    "Exclude todo keywords with a done state from refile targets"
    (not (member (nth 2 (org-heading-components)) org-done-keywords)))
