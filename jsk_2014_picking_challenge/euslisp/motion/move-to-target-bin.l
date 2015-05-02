(load "package://jsk_2014_picking_challenge/euslisp/motion/robot-motion-common.l")

(defclass target-pick-region
  ; target pick region in the shelf
  :super propertied-object
  :slots ())
(defmethod target-pick-region
  ; local coordinates of each region
  (:init () nil)
  (:a () #f(-280 1630 400))
  (:b () #f(   0 1630 400))
  (:c () #f( 280 1630 400))
  (:d () #f(-280 1400 400))
  (:e () #f(   0 1400 400))
  (:f () #f( 280 1400 400))
  (:g () #f(-280 1170 400))
  (:h () #f(   0 1170 400))
  (:i () #f( 280 1170 400))
  (:j () #f(-280 910 400))
  (:k () #f(   0 910 400))
  (:l () #f( 280 910 400))
  (:list () '(:a :b :c :d :e :f :g :h :i :j :k :l)))

(defun fold-pose-avs (arm bin)
  (let (avs)
    (setq avs (append avs (fold-pose-back (if (eq arm :larm) :rarm :larm))))  ; fold oposite arm
    (setq avs (append avs (fold-pose-mid arm)))
    (cond ((find bin '(:a :b :c :h)) (setq avs (append avs (fold-pose-up arm))))
          ((find bin '(:d :e :f :g :i)) (setq avs (append avs (fold-pose-mid arm))))
          ((find bin '(:j :k :l)) (setq avs (append avs (fold-pose-low arm))))
          (t nil))
    avs))

(defun move-to-target-bin-avs (arm bin)
  (let (c (region (instance target-pick-region :init)))
    (setq c (send *pod* :transform-vector (send region bin)))
    (send *baxter* arm :inverse-kinematics (make-cascoords :pos c) :rotation-axis t)
    (list (send *baxter* :angle-vector))))

(defun move-to-target-bin (arm bin)
  (let (avs)
    (pushback (look-at-other-side arm) avs)
    (setq avs (append avs (fold-pose-avs arm bin)))
    (send *irtviewer* :draw-objects)
    (setq avs (append avs (move-to-target-bin-avs arm bin)))
    (send *irtviewer* :draw-objects)
    (send *ri* :angle-vector-sequence avs :fast :default-controller 0 :scale 2.2)
    (send *ri* :wait-interpolation)
    avs))