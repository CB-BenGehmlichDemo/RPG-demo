
       dcl-pr arrayNew pointer extproc('ARRAYNEW');
         initialSize uns(10) const options(*nopass);
       end-pr;

       dcl-pr arrayDispose extproc('ARRAYDISPOSE');
         arrayPtr pointer;
       end-pr;

       dcl-pr arraySort extproc('ARRAYSORT');
         arrayPtr pointer;
         compareProcedure pointer(*proc) const;
         direction ind const options(*nopass);
       end-pr;

       dcl-pr arraySortNumbers extproc('ARRAYSORTNUMBERS');
         arrayPtr pointer;
         direction ind const options(*nopass);
       end-pr;

       dcl-pr arraySortStrings extproc('ARRAYSORTSTRINGS');
         arrayPtr pointer;
         direction ind const options(*nopass);
       end-pr;

       dcl-pr arrayTrimToSize extproc('ARRAYTRIMTOSIZE');
         arrayPtr pointer const;
       end-pr;

       dcl-pr arrayClear extproc('ARRAYCLEAR');
         arrayPtr pointer const;
       end-pr;

       dcl-pr arraySize uns(10) extproc('ARRAYSIZE');
         arrayPtr pointer const;
       end-pr;

       dcl-pr arrayIsEmpty ind extproc('ARRAYISEMPTY');
         arrayPtr pointer const;
       end-pr;

       dcl-pr arraySet extproc('ARRAYSET');
         arrayPtr pointer;
         objectPtr pointer const;
         objectSize uns(10) const;
         index uns(10) const;
       end-pr;

       dcl-pr arraySetNumber extproc('ARRAYSETNUMBER');
         arrayPtr pointer;
         numberObject packed(22:7) value;
         index uns(10) const;
       end-pr;

       dcl-pr arraySetString extproc('ARRAYSETSTRING');
         arrayPtr pointer;
         stringObject varchar(32767) value;
         index uns(10) const;
       end-pr;

       dcl-pr arrayRemove extproc('ARRAYREMOVE');
         arrayPtr pointer;
         index uns(10) const;
         toIndex uns(10) const options(*nopass);
       end-pr;

       dcl-pr arrayAddAll extproc('ARRAYADDALL');
         arrayPtr pointer;
         fromArrayPtr pointer const;
         index uns(10) const options(*nopass);
       end-pr;

       dcl-pr arrayAdd extproc('ARRAYADD');
         arrayPtr pointer;
         objectPtr pointer const;
         objectSize uns(10) const;
         index uns(10) const options(*nopass);
       end-pr;

       dcl-pr arrayAddNumber extproc('ARRAYADDNUMBER');
         arrayPtr pointer;
         packedObject packed(22:7) value;
         index uns(10) const options(*nopass);
       end-pr;

       dcl-pr arrayAddString extproc('ARRAYADDSTRING');
         arrayPtr pointer;
         stringObject varchar(32767) value;
         index uns(10) const options(*nopass);
       end-pr;

       dcl-pr arrayGet pointer extproc('ARRAYGET');
         arrayPtr pointer const;
         index uns(10) const;
       end-pr;

       dcl-pr arrayGetNumber packed(22:7) extproc('ARRAYGETNUMBER');
         arrayPtr pointer const;
         index uns(10) const;
       end-pr;

       dcl-pr arrayGetString varchar(32767) extproc('ARRAYGETSTRING');
         arrayPtr pointer const;
         index uns(10) const;
       end-pr;

