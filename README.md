2-2-1 multilayer perceptron (MLP)
implemented in Verilog, trained on a small dataset via fixed-point
backpropagation and tested on one held-out sample. The network
architecture has been described, mathematical foundations of gradient
descent, the use of an 8.8 fixed-point sigmoid lookup table, and key
implementation details. The design omits bias terms and employs an
identity activation approximation in hardware, illustrating how basic
neural-network concepts map to RTL.


2 Network Architecture
Our network has:
• Two 16-bit inputs x1, x2.
• One hidden layer with two neurons h1, h2.
• One output neuron y.
• No bias terms.
• Sigmoid activations in hidden and output layers implemented via an
8-bit LUT (256 entries) in 8.8 fixed point [5].

1

Figure 1: Architecture of the 2-2-1 multilayer perceptron (inputs x1, x2;
hidden neurons h1, h2; output y).
2.1 Layer Computations

h1 = σ(w11x1 + w21x2),
h2 = σ(w12x1 + w22x2),
y = σ(w31h1 + w32h2),

where all multiplications and additions are in 8.8 fixed-point format and σ(·)
denotes the sigmoid LUT [5].
3 Mathematical Formulation
3.1 Loss Function
I have used mean-squared error (MSE):
E =1/2(y − ytarget)^2
3.2 Gradient Descent Backpropagation
In backpropagation, I calculated gradients layer by layer using the chain rule.
Below I have derived each term explicitly and present the Iight updates.
3.2.1 Sigmoid and Loss Derivatives
The sigmoid function

σ(u) = 1/(1 + e−u)^2

and its derivative
σ(u) = σ(u)(1 − σ(u))

are implemented via LUT . For the MSE loss,

∂E
∂y = (y − ytarget).
