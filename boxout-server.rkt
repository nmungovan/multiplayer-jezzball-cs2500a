#lang racket
(require 2htdp/universe)
(require lang/htdp-advanced)
(provide server)

;; A 2player-game is a (make-2player-game World [Maybe World])
(define-struct 2player-game [p1 p2])
;; A Universe is a [List-of 2player-game]
(define (server name)
  (local
    [(define (need-p1-univ? univ)
       (or (empty? univ)
           (iworld? (2player-game-p2 (first univ)))))
     (define (find-game univ wrld)
       (cond [(empty? univ) #f]
             [(cons? univ)
              (if (or (eq? (2player-game-p1 (first univ)) wrld)
                      (eq? (2player-game-p2 (first univ)) wrld))
                  (first univ)
                  (find-game (rest univ) wrld))]))
     (define (add-world univ wrld)
       (cond [(need-p1-univ? univ)
              (make-bundle (cons (make-2player-game wrld #f) univ)
                           (list (make-mail wrld "p1"))
                           '())]
             [else
              (local [(define game1 (first univ))
                      (define p1 (2player-game-p1 game1))]
                (make-bundle (cons (make-2player-game p1 wrld) (rest univ))
                             (list (make-mail wrld "p2"))
                             '()))]))
     (define (relay univ wrld msg)
       (local [(define game (find-game univ wrld))]
         (cond [(false? game)
                (make-bundle univ '() (list wrld))]
               [(eq? (2player-game-p1 game) wrld)
                (p1-msg univ game wrld msg)]
               [else (p2-msg univ game wrld msg)])))
     (define (p1-msg univ game wrld msg)
       (cond [(false? (2player-game-p2 game)) (make-bundle univ '() '())]
             [(is-valid-p1-msg? msg)
              (make-bundle univ
                           (list (make-mail (2player-game-p2 game) msg))
                           '())]
             [else (make-bundle univ
                                (list (make-mail (2player-game-p1 game) '(invalid)))
                                '())]))
     (define (p2-msg univ game wrld msg)
       (if (is-valid-p2-msg? msg)
           (make-bundle univ
                        (list (make-mail (2player-game-p1 game) msg))
                        '())
           (make-bundle univ
                        (list (make-mail (2player-game-p2 game) '(invalid)))
                        '())))]
    (universe '()
              (on-new add-world)
              (on-msg relay))))

; direction? : String -> Boolean
; Is this a direction?
(define (direction? str)
  (or (string=? str "horizontal")
      (string=? str "vertical")))

; is-valid-p1-msg? : SExpr -> Boolean
; Is this a valid message from p1?
(define (is-valid-p1-msg? sexpr)
  (local [(define (is-valid-p1-msg?/world w)
            (match w
              [(list 'world (list 'posn x y) lives regions w1 w2 (list 'posn x1 y1))
               (and (is-valid-p1-msg?/wall w2)
                    (is-valid-p1-msg?/wall w1)
                    (list? regions)
                    (andmap is-valid-p1-msg?/region regions)
                    (number? x)
                    (number? y)
                    (number? x1)
                    (number? y1)
                    (number? lives))]
              [_ #f]))
          (define (is-valid-p1-msg?/wall wall)
            (match wall
              [(list 'wall dir (list 'posn tl-x tl-y) (list 'posn br-x br-y))
               (and (direction? dir)
                    (number? tl-x)
                    (number? tl-y)
                    (number? br-x)
                    (number? br-y))]
              [dir (and (string? dir) (direction? dir))]))
          (define (is-valid-p1-msg?/region region)
            (match region
              [(list 'region (list 'bounds (list 'posn tl-x tl-y) (list 'posn br-x br-y)) balls)
               (and (number? tl-x)
                    (number? tl-y)
                    (number? br-x)
                    (number? br-y)
                    (list? balls)
                    (andmap is-valid-p1-msg?/ball balls))]
              [_ #f]))
          (define (is-valid-p1-msg?/ball b)
            (match b
              [(list 'ball (list 'posn x y) (list 'vel dx dy))
               (and (number? x) (number? y) (number? dx) (number? dy))]
              [_ #t]))]
    (match sexpr
      [(list 'update world) (is-valid-p1-msg?/world world)]
      [_ #f])))

(check-expect (is-valid-p1-msg? '(hi)) #f)
(check-expect (is-valid-p1-msg? '(update (world (posn 10 10) 1 () "horizontal" "horizontal" (posn 10 5)))) #t)
(check-expect (is-valid-p1-msg? '(update #f)) #f)
; is-valid-p2-msg? : SExpr -> Boolean
; Is this a valid message from p2?
(define (is-valid-p2-msg? sexpr)
  (match sexpr
    [(list 'toggle-dir dir) (direction? dir)]
    [(list 'create-wall dir x y) (and (direction? dir) (number? x) (number? y))]
    [_ #f]))
(check-expect (is-valid-p2-msg? '(toggle-dir "horizontal")) #t)
(check-expect (is-valid-p2-msg? '(create-wall "horizontal" 1 0)) #t)
(check-expect (is-valid-p2-msg? #f) #f)
