module Engine.Display (
  display, reshape, idle
) where

import Data.IORef

import Graphics.UI.GLUT

myPoints :: [(GLfloat, GLfloat, GLfloat)]
myPoints = [ (sin (2*pi*k/100), cos (2*pi*k/100), 0) | k <- [1..100] ]

display :: IORef GLfloat -> DisplayCallback
display angle = do
  clear [ ColorBuffer ]
  loadIdentity
  a <- get angle
  renderPrimitive Points $ mapM_ (\(x,y,z) -> vertex $ Vertex3 x y z) myPoints
  swapBuffers

reshape :: ReshapeCallback
reshape size = do
  viewport $= (Position 0 0, size)
  postRedisplay Nothing

idle :: IORef GLfloat -> IdleCallback
idle angle = do
  angle $~! (+ 0.1)
  postRedisplay Nothing

