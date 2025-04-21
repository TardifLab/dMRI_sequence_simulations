#include <math.h>
#include <stdio.h>

#define GAMMA 	4258.0		/* Hz/G */
#define PI	3.141592	/* pi */
#define DEBUG	0	
/* #define TESTCODE 	For testing as regular C code... */


/*
%
%	VARIABLE DENSITY SPIRAL GENERATION:
%	----------------------------------
%
%	This is a general description of how the following C code
%	works.  This text is taken from a matlab script, vds.m, from
%	which the C code was derived.  However, note that the C code
%	runs considerably faster.
%
%
%	Function generates variable density spiral which traces
%	out the trajectory
%				 
%			k(t) = r(t) exp(i*q(t)), 		[1]
%
%	Where q IS THE SAME AS theta, and r IS THE SAME AS kr.
%
%		r and q are chosen to satisfy:
%
%		1) Maximum gradient amplitudes and slew rates.
%		2) Maximum gradient due to FOV, where FOV can
%		   vary with k-space radius r, as
%
%			FOV(r) = F0 + F1*r + F2*r*r 		[2]
%
%
%	INPUTS:
%	-------
%	smax = maximum slew rate G/cm/s
%	gmax = maximum gradient G/cm (limited by Gmax or FOV)
%	T = sampling period (s) for gradient AND acquisition.
%	N = number of interleaves.
%	F0,F1,F2 = FOV coefficients with respect to r - see above.
%	rmax= value of k-space radius at which to stop (cm^-1).
%		rmax = 1/(2*resolution);
%
%
%	OUTPUTS:
%	--------
%	k = k-space trajectory (kx+iky) in cm-1.
%	g = gradient waveform (Gx+iGy) in G/cm.
%	s = derivative of g (Sx+iSy) in G/cm/s.
%	time = time points corresponding to above (s).
%	r = k-space radius vs time (used to design spiral)
%	theta = atan2(ky,kx) = k-space angle vs time.
%
%
%	METHODS:
%	--------
%	Let r1 and r2 be the first derivatives of r in [1].	
%	Let q1 and q2 be the first derivatives of theta in [1].	
%	Also, r0 = r, and q0 = theta - sometimes both are used.
%	F = F(r) defined by F0,F1,F2.
%
%	Differentiating [1], we can get G = a(r0,r1,q0,q1,F)	
%	and differentiating again, we get S = b(r0,r1,r2,q0,q1,q2,F)
%
%	(functions a() and b() are reasonably easy to obtain.)
%
%	FOV limits put a constraint between r and q:
%
%		dr/dq = N/(2*pi*F)				[3]	
%
%	We can use [3] and the chain rule to give 
%
%		q1 = 2*pi*F/N * r1				[4]
%
%	and
%
%		q2 = 2*pi/N*dF/dr*r1^2 + 2*pi*F/N*r2		[5]
%
%
%
%	Now using [4] and [5], we can substitute for q1 and q2
%	in functions a() and b(), giving
%
%		G = c(r0,r1,F)
%	and 	S = d(r0,r1,r2,F,dF/dr)
%
%
%	Using the fact that the spiral should be either limited
%	by amplitude (Gradient or FOV limit) or slew rate, we can
%	solve 
%		|c(r0,r1,F)| = |Gmax|  				[6]
%
%	analytically for r1, or
%	
%	  	|d(r0,r1,r2,F,dF/dr)| = |Smax|	 		[7]
%
%	analytically for r2.
%
%	[7] is a quadratic equation in r2.  The smaller of the 
%	roots is taken, and the real part of the root is used to
%	avoid possible numeric errors - the roots should be real
%	always.
%
%	The choice of whether or not to use [6] or [7], and the
%	solving for r2 or r1 is done by calcthetadotdot().
%
%	Once the second derivative of theta(q) or r is obtained,
%	it can be integrated to give q1 and r1, and then integrated
%	again to give q and r.  The gradient waveforms follow from
%	q and r. 	
%
%	Brian Hargreaves -- Sept 2000.
%
%
*/






/* ----------------------------------------------------------------------- */
void calcthetadotdot(slewmax,gradmax,kr,krdot,Tgsample,Tdsample,Ninterleaves,
				fov,numfov, thetadotdot, krdotdot)
/*
 * Function calculates the 2nd derivative of kr and theta at each
 * sample point within calc_vds().  ie, this is the iterative loop
 * for calc_vds.  See the text at the top of this file for more details
 * */

double slewmax;		/*	Maximum slew rate, G/cm/s		*/
double gradmax;		/* 	maximum gradient amplitude, G/cm	*/
double kr;		/* 	Current kr. */
double krdot;		/*	Current krdot. */
double Tgsample;	/*	Gradient Sample period (s) 	*/
double Tdsample;	/*	Data Sample period (s) 		*/
int Ninterleaves;	/*	Number of interleaves			*/
double *fov;		/*	FOV coefficients		*/
int numfov;		/*	Number of FOV coefficients		*/
double *thetadotdot;	/*	[output] 2nd derivative of theta.	*/
double *krdotdot;	/*	[output] 2nd derivative of kr		*/

/* ----------------------------------------------------------------------- */
{
double fovval=0;	/* FOV for this value of kr	*/
double dfovdrval=0;	/* dFOV/dkr for this value of kr	*/
double gmaxfov;		/* FOV-limited Gmax.	*/
double maxkrdot;
int count;

double tpf;	/* Used to simplify expressions. */
double tpfsq;	/* 	" 		"        */

double qdfA, qdfB, qdfC;	/* Quadratic formula coefficients */
double rootparta,rootpartb;



if (DEBUG>1)
	{
	printf("calcthetadotdot:  slewmax=%8.2f, gmax=%6.2f, \n",
			slewmax,gradmax);
	printf("        kr=%8.4f, Tg=%9.6f, N=%d, nfov=%d \n", 
			slewmax,gradmax, kr,Tgsample,Ninterleaves,numfov);
	}

	/* Calculate the actual FOV and dFOV/dkr for this R,
	 * based on the fact that the FOV is expressed 
	 * as a polynomial in kr.*/

for (count=0; count < numfov; count++)
	{
	fovval = fovval + fov[count]*pow(kr,count);
	if (count > 0)
		dfovdrval = dfovdrval + count*fov[count]*pow(kr,count-1);
	}

	/* Calculate FOV limit on gmax.  This is the rate of motion along
	 * a trajectory, and really should not be a limitation.  Thus,
	 * it is reasonable to comment out the following lines. */

gmaxfov = 1/GAMMA / fovval / Tdsample;	
if (gradmax > gmaxfov)
	gradmax = gmaxfov;	


	/* Maximum dkr/dt, based on gradient amplitude.  */

maxkrdot = sqrt(pow(GAMMA*gradmax,2) / (1+pow(2*PI*fovval*kr/Ninterleaves,2)));
if (DEBUG>1)
	printf("calcthetadotdot:  maxkrdot = %g \n",maxkrdot);

	/* These two are just to simplify expressions below */
tpf = 2*PI*fovval/Ninterleaves;
tpfsq = pow(tpf,2);
if (DEBUG>1)
	printf("calcthetadotdot:  tpf = %8.4f,  tpfsq = %8.4f  \n",tpf,tpfsq);




if (krdot > maxkrdot)	/* Then choose krdotdot so that krdot is in range */
	{	
	*krdotdot = (maxkrdot - krdot)/Tgsample;
	}

else			/* Choose krdotdot based on max slew rate limit. */
	{

		/* Set up for quadratic formula solution. */

	qdfA = 1+tpfsq*kr*kr;
	qdfB = 2*tpfsq*kr*krdot*krdot + 
			2*tpfsq/fovval*dfovdrval*kr*kr*krdot*krdot;
	qdfC = pow(tpfsq*kr*krdot*krdot,2) + 4*tpfsq*pow(krdot,4) +
			pow(tpf*dfovdrval/fovval*kr*krdot*krdot,2) +
			4*tpfsq*dfovdrval/fovval*kr*pow(krdot,4) -
			pow(GAMMA*slewmax,2);

	if (DEBUG>1)
		printf("calcthetadotdot:  qdfA, qdfB, qdfC = %g, %g, %g \n",
				qdfA, qdfB, qdfC);

	rootparta = -qdfB/(2*qdfA);
	rootpartb = qdfB*qdfB/(4*qdfA*qdfA) - qdfC/qdfA;
	if (DEBUG>1)
		printf("calcthetadotdot:  rootparta, rootpartb = %g, %g \n",
				rootparta, rootpartb);

	if (rootpartb < 0)	/* Safety check - if complex, take real part.*/

		*krdotdot = rootparta;

	else
		*krdotdot = rootparta + sqrt(rootpartb);


	/* Could check resulting slew rate here, as in q2r21.m. */
	}

	/* Calculate thetadotdot */

	
*thetadotdot = tpf*dfovdrval/fovval*krdot*krdot + tpf*(*krdotdot);

if (DEBUG>1)
	printf("calcthetadot:  r=%8.4f,  r'=%8.4f,  r''=%g  q''=%g \n",
		kr,krdot,*krdotdot,*thetadotdot);

}


/* ----------------------------------------------------------------------- */
void calc_vds(slewmax,gradmax,Tgsample,Tdsample,Ninterleaves,fov,numfov,krmax,
		ngmax,xgrad,ygrad,numgrad)

/*	Function designs a variable-density spiral gradient waveform
 *	that is defined by a number of interleaves, resolution (or max number
 *	of samples), and field-of-view.  
 *	The field-of-view is a polynomial function of the
 *	k-space radius, so fov is an array of coefficients so that
 *
 *	FOV = fov[0]+fov[1]*kr+fov[2]*kr^2+ ... +fov[numfov-1]*kr^(numfov-1)
 *
 * 	Gradient design is subject to a constant-slew-rate-limit model,
 * 	with maximum slew rate slewmax, and maximum gradient amplitude
 * 	of gradmax.  
 *
 * 	Tgsample is the gradient sampling rate, and Tdsample is the data
 * 	sampling rate.  It is highly recommended to OVERSAMPLE the gradient
 * 	in the design to make the integration more stable.
 *
 * */

double slewmax;		/*	Maximum slew rate, G/cm/s		*/
double gradmax;		/* 	maximum gradient amplitude, G/cm	*/
double Tgsample;	/*	Gradient Sample period (s)		*/
double Tdsample;	/*	Data Sample period (s)			*/
int Ninterleaves;	/*	Number of interleaves			*/
double *fov;		/*	FOV coefficients		*/
int numfov;		/*	Number of FOV coefficients		*/
double krmax;		/*	Maximum k-space extent (/cm)		*/
int ngmax;		/*	Maximum number of gradient samples	*/
double **xgrad;		/* 	[output] X-component of gradient (G/cm) */
double **ygrad;		/*	[output] Y-component of gradient (G/cm)	*/
int *numgrad;		/* 	[output] Number of gradient samples */

/* ----------------------------------------------------------------------- */
{
int gradcount=0;

double kr=0;			/* Current value of kr	*/
double krdot = 0;		/* Current value of 1st derivative of kr */
double krdotdot = 0;		/* Current value of 2nd derivative of kr */

double theta=0;			/* Current value of theta */
double thetadot=0;		/* Current value of 1st derivative of theta */
double thetadotdot=0;		/* Current value of 2nd derivative of theta */

double lastkx=0;		/* x-component of last k-location. */
double lastky=0;		/* y-component of last k-location */
double kx, ky;			/* x and y components of current k-location */

double *gxptr, *gyptr;		/* Pointers to gradient variables. */




if (DEBUG>0)
	printf("calc_vds:  First run. \n");

	/* First just find the gradient length. */

while ((kr < krmax) && (gradcount < ngmax))
	{
	calcthetadotdot(slewmax,gradmax,kr,krdot,Tgsample,Tdsample,
			Ninterleaves, fov,numfov, &thetadotdot, &krdotdot);

	/* Integrate to obtain new values of kr, krdot, theta and thetadot:*/

	thetadot = thetadot + thetadotdot * Tgsample;
	theta = theta + thetadot * Tgsample;

	krdot = krdot + krdotdot * Tgsample;
	kr = kr + krdot * Tgsample;

	gradcount++;

	}



	/* Allocate memory for gradients. */

*numgrad = gradcount;
if (DEBUG>0)
	printf("Allocating for %d gradient points. \n",*numgrad);

*xgrad = (double *)malloc(*numgrad*sizeof(double));
*ygrad = (double *)malloc(*numgrad*sizeof(double));


	/* Reset parameters */

kr=0;
krdot=0;
theta=0;
thetadot=0;
gradcount=0;
gxptr = *xgrad;
gyptr = *ygrad;


	/* Now re-calculate gradient to find length. */

if (DEBUG>0)
	printf("calc_vds:  First run. \n");

while ((kr < krmax) && (gradcount < ngmax))
	{
	calcthetadotdot(slewmax,gradmax,kr,krdot,Tgsample,Tdsample,
			Ninterleaves, fov,numfov, &thetadotdot, &krdotdot);

	/* Integrate to obtain new values of kr, krdot, theta and thetadot:*/

	thetadot = thetadot + thetadotdot * Tgsample;
	theta = theta + thetadot * Tgsample;

	krdot = krdot + krdotdot * Tgsample;
	kr = kr + krdot * Tgsample;

	/* Define current gradient values from kr and theta. */

	kx = kr * cos(theta);
	ky = kr * sin(theta);
	*gxptr++ = (1/GAMMA/Tgsample) * (kx-lastkx);
	*gyptr++ = (1/GAMMA/Tgsample) * (ky-lastky);
	lastkx = kx;
	lastky = ky;

	if (DEBUG>0)
		printf("Current kr is %6.3f \n",kr);

	gradcount++;
	}

}



#ifdef TESTCODE

int main(void)

{
double *gx, *gy;
int ng;
double fov[4];
double thdd, krdd;
FILE *outfile;

fov[0] = 24.0;

printf("Calculating waveform.\n");
calc_vds(15000.0, 4.0, 0.000001, 40, fov, 1, 5.0, &gx, &gy, &ng); 
printf("%d gradient samples \n",ng);

/*calcthetadotdot(15000.0, 4.0, 1.0,100.0,.000004, 60, fov, 1, &thdd,&krdd);*/

outfile = fopen("vdstest", "wb");
if (outfile != NULL)
	{
	fwrite(gx,sizeof(double),ng,outfile);
	fwrite(gy,sizeof(double),ng,outfile);
	}
fclose(outfile);
}

#endif

