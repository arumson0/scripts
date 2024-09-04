fritic2. A bash wrapper function for aoterodelaroza's critic2 program.
https://aoterodelaroza.github.io/critic2/

POSSIBLE USES:

`fritic2 FILE.in`
  Reads the crystal geometry from FILE.in. Great for reading geometric parameters from FILE.in with fritic2 options.
  
`fritic2 FILE1.in FILE2.in`
  Reads the crystal geometry file FILE1.in and writes it to FILE2.in. Great for converting betweeen input formats, or converting outputs to inputs.
  
`fritic2 FILE1.in FILE2.in ADDVAC d`
  Reads the crystal geometry file FILE1.in, adds `d` angstroms of vacuum to the z-direction, and writes the changes to FILE2.in. Great for surfaces.
  
`fritic2 FILE1.in FILE2.in x y z`
  Reads the crystal geometry file FILE1.in, replicates the cell in integer multiples, x, y, z, along the a, b, c lattice vectors respectively, and and writes the changes to FILE2.in. Great for building supercells.
  

OPTIONS:

`-a`
  prints the a-lattice parameter.
`-b`
  prints the b-lattice parameter.
`-c`
  prints the c-lattice parameter.
`-v`
  prints the unit cell volume.
`-n`
  prints the number of atoms in the cell.
`-A`
  prints the area of the plane formed by the a and b lattice vectors.

For example:
`fritic2 -a -b geometry.in`
