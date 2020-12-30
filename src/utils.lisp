(in-package :pipelines-viewer)

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
