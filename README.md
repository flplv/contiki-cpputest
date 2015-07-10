# contiki-cpputest
Template to run cuntiki over CppUTest 


# What is it
Its a integration of the CppUTest testing framework to work with Contiki. In this first version it is poorly designed but works in a almost full featured fashion. You can test your application, your protothreads and the contiki's internals, including the whole uIP stack if you want.

# How it works
It's composed of 3 makefiles and a platform fake. They build a library with your application and contiki in it, them build the tests and link all togetuer in a test executable.

### Makefile
This is just a make target forwarder, shouldn't exist in a propper design. 

### makefile.contiki.mk
This is the contii makefile. The same you would have in your contiki application project, except it has been modified to build a library, instead a binary, when the key `MAKE_CONTIKI_LIB` is defined.

### makefile.cpputest.mk
This is an ugly-messy-stinky makefile to build the tests and then link the `your-contiki-app.native.a` into the testing executable. 

### tests/platform_fakes.c
There are symbols that will be missing to your application build, becouse we are using the contiki's native platform to build the tests and your application will probabbly be another. This is the file where you create the fakes to enable linking.


# TODO
There is a lot of refactoring to do. 
 - There should be a good integration between CppUTest and contiki, probably a tests platform inside contiki where low levels fakes could be installed to simulate the hardware: sensors, phys, etc. 
 - The makefiles should integrate better.
