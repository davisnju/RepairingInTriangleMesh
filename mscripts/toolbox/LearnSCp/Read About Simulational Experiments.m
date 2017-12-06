Vojislav KECMAN's Book:

	        LEARNING AND SOFT COMPUTING
Support Vector Machines, Neural Networks and Fuzzy Logic Models
               The MIT Press, Cambridge, MA, 2000
	            ISBN 0-262-11255-8 
            608 pp., 268 illus., $US60.00/£41.50 (cloth)

          THE COMPLETE DESCRIPTION OF (i.e., THE MANUAL FOR) 
                SIMULATION EXPERIMENTS IS GIVEN IN THE BOOK

   The author strongly recommends reading of, and going through, all the theoretical
presentations in the book BEFORE running the corresponding simulation experiments!

CHAPTER 1 
	The simulation experiments in chapter 1 have the purpose of familiarizing the
reader with the field of interpolation/approximation, i.e. (nonlinear)
regression. (Nonlinear regression and classification are the core problems of
the whole soft computing anyway). The programs that are used in chapter 2 on
support vector machines cover the fields of both classification and regression
by applying the SVM technique. There is no need for manual here because all
routines are 'simple' (if there is anything simple when programming is
concerned). The experiments are aimed at reviewing many basic facets of
regression (notably, problems of over- and underfitting, influence of noise and
smoothness of approximation). Note that first two approximators are classic
ones. Namely, they are one-dimensional algebraic polynomials and Chebyshev
polynomials. The last three belong to the RBF approximators. They are linear
splines, cubic splines and Gaussian radial basis functions. Finally, there is a fuzzy 
logic modeling toolbox containing several standard membership functions.
      	Be aware of the following facts about the program Aproxim:
		1. It is developed for interpolation/approximation problems. 
		2. It is designed for one-dimensional input data (y = f(x)). 
		3. It is user friendly, even for beginners in using Matlab, 	
		    but you must cooperate. It prompts you to select, to 
		    define and/or to choose different things. 
CHAPTER 2 
	The simulation experiments in chapter 2 have the purpose of familiarizing the
reader with support vector machines. Two programs cover both the classification
(svclass.m) and the regression (svregress.m) by applying the SVMs technique. There
is no need for extended manual here because both programs are user-friendly. The 
experiments are aimed particularly at understanding basic concepts in SVMs fields. 
This concerns primarily the notions of support vectors, decision function, decision
boundary, indicator function and canonical (hyper)plane. We used 1- and
2-dimensional patterns in the case of classification and merely R1 -> R1
mappings in the case of regression for the sake of visualization of the
fundamental basic concepts. 
We highly recommend meticulous analysis of all resulting graphs that were made 
with great care and that nicely display possibly difficult to understand basic concepts
and terminology used in SV machines field. 
	Be aware of the following facts about the programs svclass.m and svregres.m.
		1. They are developed for classification and regression tasks respectively. 
		2. They are designed for 1-D and 2-D classification and 1-D regression problems. 
		3. They are user-friendly, even for beginners in using Matlab, but you must
		     cooperate. It prompts you to select, to define and/or to choose different
		     things. 
CHAPTER 3 
	We have not provided any program for learning and modeling by using perceptron
or linear neuron. They are the simplest possible learning paradigms anyway, and
it may be very useful that the interested reader write his/hers own routines
starting with them. 
Write numerical implementations of the perceptron learning
algorithms as given in Table 3.1. Design also your own learning code for linear
neuron. Start with Method 1. It is just about calculating pseudoinversion of an
input data matrix XT. Implement Method 4 to be closer to the spirit of an
iterative learning. It is online, recursive, first order gradient descent method.
Generate a data set consisting of a small number of vectors, i.e., training
data pairs in one- or two-dimensions, each belonging to one of two classes. There
are many learning issues to analyze.
	1. Experiment with non-overlapping classes and perceptron learning rule first.
Start with random initial weight vector (it can also be w0 = 0), keep it
constant and change the learning rate to see whether an initialization has any
impact on final separation of classes. Now keep a learning rate fixed and start
each learning cycle with different initial weight vectors.
	2. Generate classes with overlapping and try to separate them by using
perceptron.
	3. Repeat all the calculations above by using your linear neuron code. In
particular, check the influence of learning rate on the learning process now.
	4. Generate data for linear regression and experiment with linear neuron
modeling capacity. Play with different noise level, learning rates,
initialization of weights and similar.
	a) In particular, it may be very useful to compare method 3 ('ideal' gradient
	   learning in batch version) with method 4 (on-line version of a gradient method).
	   Compare differences while changing learning rate. 
	b) Write a numerical implementation of a recursive least squares algorithms as given in 
	   Tables 3.3 and 3.4. Compare performances of the RLS with LMS algorithm in terms of 
	    number of iteration and computing times on a given data set.
	5. After getting some expertise repeat all the examples from this chapter by
applying your software.

General advice in designing programs for iterative learning is that you should
always control what is happening with your error function E. Start with using sum
of error squares and display always both the number of iteration steps and the
change of error E after every iteration. Store the error E and plot its changes
after learning. While solving 2-D classification problems, it may also be very
useful to plot both the data points and decision boundary after every iteration.

CHAPTER 4 
	The simulation experiments in chapter 4 have the purpose of familiarizing the
reader with the EBP learning in multilayer perceptrons aimed at solving
one-dimensional regression problems. However, learning algorithm is written in a
matrix form, i.e., it is a batch algorithm, and it works for any number of
inputs and outputs. We work with one-dimensional examples merely for the sake
of visualization in the ebp.m routine.  We prepared three examples and you may make
as many different examples as needed. To run any of examples type ebp.m and follow the
instructions. See the description of all input variables in the program ebp.m.
The experiments are aimed at reviewing many basic facets of the EBP learning
(notably, learning dynamics in dependence of the learning rate eta, smoothing
effects obtained by decreasing the number of HL neurons, influence of noise and
smoothing effects of early stopping). Important part is to analyze the
geometry of learning, i.e., how the HL AFs are changing during the course of
learning. 
	Be aware of the following facts about the program ebp.m:
		1. It is developed for one-dimensional nonlinear regression problems. 
		2. However learning part is in a matrix form and it can be used for more
		     complex learning tasks. If you want to perform those, you should 
		     rewrite the input, test and graphical parts of program. 
		3. The learning is the gradient descent with momentum. 
		4. It is user friendly, even for beginners in using Matlab, but you
		     must cooperate. Read carefully the description part of the ebp.m routine 
		     first. Giving the input data will be easier. The ebp.m routine prompts you 
		     to select, to define and/or to choose different things during the learning. 
		5. Analyze carefully the graphic windows presented. There are a lot of 
		     answers to many issues of learning in them. 
CHAPTER 5 
	The simulation experiments in chapter 5 have the purpose of familiarizing the
reader with the regularization networks that are better known as the RBFs
networks. The program rbf.m is aimed at solving 1-dimensional regression
problems by using Gaussian basis functions. Learning algorithm is a standard
RBFs network batch algorithm given by equation (5.16). We work with one-dimensional
examples merely for the sake of visualization of all results.In running simulation
just follow the popup menus and select the inputs you want. 
The experiments are aimed at reviewing many basic facets of
the RBF batch learning (notably, influence of the Gaussian bells shapes on the
approximation, smoothing effects obtained by decreasing the number of HL
neurons, smoothing effects obtained by changing the regularization parameter lambda
and influence of noise). 
	Be aware of the following facts about the program rbf.m:
		1. It is developed for one-dimensional nonlinear regression problems. 
		2. However learning part is in a matrix form and it can be used for 
		     more complex learning tasks. If you want to perform those, you 
		     should rewrite the input, test and graphical parts of program. 
		3. The learning takes place in an off-line or batch algorithm given by (5.16). 
		4. rbf.m is user friendly program, even for beginners in using Matlab, 
		    but you must cooperate. Read carefully the description part of the 
		     rbf.m routine first. The program prompts you to select, to define 
		     and/or to choose different things during the learning. 
		5. Analyze carefully the resulting graphic windows. There are many 
		    answers to various issues of learning and modeling by using RBFs 
		    networks in them.
CHAPTER 6 
	The simulation experiments in chapter 6 have the purpose of familiarizing the
reader with the fuzzy logic modeling tools. There are two user-friendly programs
for performing a variety of fuzzy modeling tasks. They can be found in the two
directories:
			 fuzzy1 and fuzzy2.  

Fuzzy1 can be used to develop other fuzzy logic models while fuzzy2 is merely demo
program devoted to simulation of a given problem. Thus the reader can not create
his/hers own models in a fuzzy2 routine. However, s/he can explore various
interesting aspects of FL modeling by using a fuzzy2 model. Both programs have
nice graphic interface and they are user friendly. This means that the user
merely follows the popup menus and graphic windows. 
	You can perform various experiments that are aimed at reviewing many basic facets 
of the fuzzy logic modeling (notably, the influence of the membership functions shape 
and overlap on the accuracy of model, the influence of the rule basis on the model
performance and the impact of the inference and defuzzification operators on
the modeling final results.


