/*
  Copyright (C) 2011 Tao Ju

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public License
  (LGPL) as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

class SOGReader : public VolumeReader
{
private:

	char sogfile[1024] ;

	/* Recursive reader */
	void readSOG( FILE* fin, Volume* vol, int off[3], int len, bool writeData = true )
	{
		// printf("%d %d %d: %d\n", off[0], off[1], off[2], len) ;
		char type ;
		int noff[3] ;
		int nlen = len / 2 ;
		
		// Get type
		fread( &type, sizeof( char ), 1, fin ) ;

		if ( type == 0 )
		{
			// Internal node
			for ( int i = 0 ; i < 2 ; i ++ )
				for ( int j = 0 ; j < 2 ; j ++ )
					for ( int k = 0 ; k < 2 ; k ++ )
					{
						noff[0] = off[0] + i * nlen ;
						noff[1] = off[1] + j * nlen ;
						noff[2] = off[2] + k * nlen ;
						readSOG( fin, vol, noff, nlen, writeData ) ;
					}
		}
		else if ( type == 1 )
		{
			// Empty node
			char sg ;
			fread( &sg, sizeof( char ), 1, fin ) ;

			if (writeData)
			{
				for ( int i = 0 ; i <= len ; i ++ )
					for ( int j = 0 ; j <= len ; j ++ )
						for ( int k = 0 ; k <= len ; k ++ )
						{
							noff[0] = off[0] + i ;
							noff[1] = off[1] + j ;
							noff[2] = off[2] + k ;
							vol->setDataAt( noff[0], noff[1], noff[2], - sg ) ;
						}
			}
		}
		else if ( type == 2 )
		{
			// Leaf node
			char sg ;
			fread( &sg, sizeof( char ), 1, fin ) ;

			float coord[3] ;
			fread( coord, sizeof( float ), 3, fin ) ;

			if (writeData)
			{
				int t = 0 ;
				for ( int i = 0 ; i < 2 ; i ++ )
					for ( int j = 0 ; j < 2 ; j ++ )
						for ( int k = 0 ; k < 2 ; k ++ )
						{
							noff[0] = off[0] + i ;
							noff[1] = off[1] + j ;
							noff[2] = off[2] + k ;
							vol->setDataAt( noff[0], noff[1], noff[2], - (( sg >> t ) & 1) ) ;
							t ++ ;
						}
			}
		}
		else if ( type == 3 )
		{
			// Pseudo-leaf node
			char sg ;
			fread( &sg, sizeof( char ), 1, fin ) ;

			float coord[3] ;
			fread( coord, sizeof( float ), 3, fin ) ;

			// go down to leaves
			for ( int i = 0 ; i < 2 ; i ++ )
				for ( int j = 0 ; j < 2 ; j ++ )
					for ( int k = 0 ; k < 2 ; k ++ )
					{
						noff[0] = off[0] + i * nlen ;
						noff[1] = off[1] + j * nlen ;
						noff[2] = off[2] + k * nlen ;
						readSOG( fin, vol, noff, nlen, false ) ; // dont write data
					}

		}
		else
		{
			printf("Wrong! Type: %d\n", type);
		}


	}

public:
	/* Initializer */
	SOGReader( char* fname )
	{
		sprintf( sogfile, "%s", fname ) ;
		FILE* fin = fopen( fname, "rb" ) ;


		if ( fin == NULL )
		{
			printf("Can not open file %s.\n", fname) ;
		}

		fclose( fin ) ;
	}

	/* Read volume */
	Volume* getVolume( )
	{
		int sx, sy, sz ;

		FILE* fin = fopen( sogfile, "rb" ) ;

		// Process header
		fread( &sx, sizeof( int ), 1, fin ) ;
		sy = sx ;
		sz = sx ;
		printf("Dimensions: %d %d %d\n", sx, sy, sz ) ;

		Volume* rvalue = new Volume( sx + 1, sy + 1, sz + 1 ) ;

		// Recursive reader
		int off[3] = { 0, 0, 0 } ;
		readSOG( fin, rvalue, off, sx ) ;

		printf("Done reading.\n") ;
		fclose( fin ) ;
		return rvalue ;
	}

	/* Get resolution */
	void getSpacing( float& ax, float& ay, float& az )
	{
		ax = 1 ;
		ay = 1 ;
		az = 1 ;
	}

};