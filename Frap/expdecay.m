function valout=expdecay(coeffs,xdata)

valout=coeffs(1)*exp(-xdata/coeffs(2))+coeffs(3);