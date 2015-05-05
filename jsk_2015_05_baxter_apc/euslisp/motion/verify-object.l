(load "package://jsk_2014_picking_challenge/euslisp/robot-visualization.l")

(ros::load-ros-manifest "roseus")
(ros::load-ros-manifest "jsk_2014_picking_challenge")

(setq verify-object-msg nil)
(defun verify-object-cb (msg) (setq verify-object-msg msg))
(ros::subscribe "/object_verification/output"
                jsk_2014_picking_challenge::ObjectRecognition
                #'verify-object-cb)

(defun verify-object (arm target-object &key (timeout 20))
  (ros::spin-once)
  (let ((now (ros::time-now))
        (stamp (send (send verify-object-msg :header) :stamp)))
    (while
      (< (send stamp :sec) (send now :sec))
      (unix::usleep 1000)
      (ros::spin-once)
      (setq correct? (string= target-object (send verify-object-msg :matched)))
      (when (> (- (send (ros::time-now) :sec) (send now :sec)) timeout) (return)))
    (publish-popup-text target-object "base_footprint" (ros::coords->tf-pose (send *baxter* arm :end-coords)))
    correct?))