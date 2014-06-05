##############
#Perceptron Example
#Jed Dougherty
#April 7, 2014
##############


import numpy as np
import matplotlib.mlab as ml
import matplotlib.pyplot as plt


#The below algorithm learns to recognize clock digits
#as odd or even
#I built the digits as a separate csv and read them in
training = np.genfromtxt('digits.csv', delimiter=',')

iris = np.genfromtxt('iris.csv', delimiter=',',skip_header = 1)

#we desire to have the output separated between evens and odds
d_desired = [-1,1,-1,1,-1,1,-1,1,-1,1]
m, n = training.shape
#Set initial weights to 1
d_weights = np.ones(n)
d_w = d_weights
#set a threshold
threshold = .05
sign = 0

#Perceptron function
def perceptron(train, weights, w, desired,set_size):

  x = 1
  #x is the sum of the squared change in each iteration
  #once it goes below a certain threshold
  #and stays there for a passthrough of the inputs
  #I stop the algorithm
  while x > threshold:
    for i in range(0,set_size):
      #Print each w so we can see the situation evolve
      print(w)
      #if the dot product of my w and my given row of x <= 0
      if w.dot(train[i,:]) <= 0:
        #then set the sign negative
        sign = -1
      else:
        sign = 1
      #check to see if our desired outcome agrees with our
      #predicted sign
      if desired[i]*sign < 0:
        #if it does not, then update the w
        w = w + train[i,:]*desired[i]
    #calculate the difference between our prior and current
    #weights
    x = sum((weights - w)**2)
    #reset the weights
    weights = w
  return(weights)

#Returns the desired w
print(perceptron(training,d_weights,d_w,d_desired,m))

#Here we can look again at the iris data set.
#while one of the sets was linearly separable,
#as noted in the description of the dataset,
#the other two were not. We can try the
#perceptron algorithm on the Virginica flower.
#It cannot linearly separate, and so
#my while loop will run forever.

def lin_seperable(ls):
  X = iris[:,0:4]
  p, q = X.shape
  Y = np.ones(p)
  if ls == 1:
    Y[0:49] = -1 #setosa
  else:
    Y[50:99] = -1 #virginica
  new_weights = np.ones(q) * .01
  copy = new_weights
  perceptron(X, new_weights, copy, Y, p)

#we can see that the perceptron
#converges when looking at setosa
#but divergerse when looking at virginica
lin_seperable(1)
# Uncomment at your own risk
# lin_seperable(0)

