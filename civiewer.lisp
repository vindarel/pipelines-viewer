#!/usr/bin/env ciel

;;; Utils
(defun git-config-lines ()
  (let* ((git-config ".git/config"))
     (str:lines (str:from-file git-config))))

(defun first-remote-url ()
  (let* ((lines (git-config-lines))
         (index-first-remote (position-if (lambda (line)
                                            (str:starts-with-p "[remote" line))
                                          lines))
         (index-remote-url (when index-first-remote
                             (position-if (lambda (line)
                                            (str:contains? ".git" line))
                                          lines
                                          :start index-first-remote))))
    (when (null index-remote-url)
      (error "We could not find a remote git URL from the .git/config."))
    (str:trim (elt lines index-remote-url))))

(defun get-user/project (url)
  (ppcre:register-groups-bind (user project)
                   (".*:(.*)\/(.*)\.git" url)
    (list user project)))

;;; pipelines viewer

(defparameter +gitlab-server+ "https://gitlab.com")

(defparameter +gitlab-api-pipelines+ "/api/v4/projects/~a/pipelines"
  "API endpoint with project-id placeholder.")

(defvar *server* +gitlab-server+)

(defun build-url (project-id)
  (str:concat *server* (format nil +gitlab-api-pipelines+ project-id)))

(defun get-pipelines (project-id)
  (let* ((url (build-url project-id))
         (http-result (dex:get url)))
    ;; (jojo:parse http-result)))
    (json:read-json http-result)))

(defun is-success (pipeline)
  (string-equal (access:access pipeline :|status|)
                "success"))


(defun is-error (pipeline)
  (string-equal (access:access pipeline :|status|)
                "failed"))

(defun show-last-pipelines (data)
  ;; (loop for item in (str:substring 0 10 data)
  ;; warn: by reading JSON with shasht we get an array, not a list.
  (loop for item across data
        for n from 0 upto 10
     ;; with the-most-recent-pipeline-failed = (is-error (first data))
     with the-most-recent-pipeline-failed = (is-error (elt data 0))
     do (cond
          ((is-success item)
           (format t "~a~t ~a~&"
                   (cl-ansi-text:green "OK")
                   (access:access item :|updated_at|)))
          ((is-error item)
           (format t "~a~t ~a~&"
                   (cl-ansi-text:red "FAILED")
                   (access:access item :|updated_at|)))
          (t
           (format t "~a~t ~a~&"
                   (access:access item :|status|)
                   (access:access item :|updated_at|))))
     finally
       (when the-most-recent-pipeline-failed
         ;; (format t "~%See your failing pipeline here: ~a~&" (access:access (first data) :|web_url|)))))
         (format t "~%See your failing pipeline here: ~a~&" (access:access (elt data 0) :|web_url|)))))

#+(or nil)
(get-pipelines "vindarel%2Fabelujo")
#+(or nil)
(show-last-pipelines (get-pipelines "vindarel%2Fabelujo"))

(defun run (args)
  "Optional arguments: username project. Otherwise, extract them from the first .git/config remote URL."
  (let* (project-id)
    (cond
      ;; We have CLI args.
      (args
       (setf project-id (format nil "~a%2F~a" (second args) (third args))))
      ;; Read the .git/config, consider the first remote URL.
      (t
       (let* ((remote-url (first-remote-url))
              (user/project (get-user/project remote-url)))
         (setf project-id (format nil "~a%2F~a" (first user/project) (second user/project))))))

    (show-last-pipelines (get-pipelines project-id))))

(defun main ()
  (run (rest ciel-user:*script-args*)))

#+ciel
(main)
