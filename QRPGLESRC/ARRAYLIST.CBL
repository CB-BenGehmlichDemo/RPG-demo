
       ctl-opt nomain option(*srcstmt) bnddir('QC2LE':'UTILS');

       dcl-c ARRAY_SIZE %size(arrayTpl);
       dcl-c ENTRY_SIZE %size(entryTpl);
       dcl-c DEFAULT_SIZE 16;

      /include qcopysrc,memcpy
      /include qcopysrc,quicksort
      /include qcopysrc,utils

       dcl-ds arrayTpl qualified template align;
         data pointer;
         size uns(10);
         allocatedSize uns(10);
         modCount uns(10);
         sortDirection ind;
       end-ds;

       dcl-ds entryTpl qualified template align;
         parentPtr pointer;
         objectPtr pointer;
         objectSize uns(10);
         reservedForAlignment char(12);
       end-ds;

   
       dcl-proc arrayNew export;

         dcl-pi *n pointer;
           initialSize uns(10) const options(*nopass);
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);
         dcl-s arrayPtr pointer inz(*null);
         dcl-s initialSize_ uns(10) inz;

         if (%parms > 0);
           initialSize_ = initialSize;
         else;
           initialSize_ = DEFAULT_SIZE;
         endif;

         allocSpace(arrayPtr:ARRAY_SIZE);
         allocSpace(array.data:ENTRY_SIZE * initialSize_);
         array.allocatedSize = initialSize_;
         array.size = 0;

         return arrayPtr;

       end-proc;

     *
       dcl-proc arrayDispose export;

         dcl-pi *n;
           arrayPtr pointer;
         end-pi;

         if (arrayPtr <> *null);
           arrayClear(arrayPtr);
           deallocSpace(arrayPtr);
         endif;

       end-proc;

   
       dcl-proc arraySort export;

         dcl-pi *n;
           arrayPtr pointer;
           compareProcedure pointer(*proc) const;
           direction ind const options(*nopass);
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);
         dcl-s direction_ ind inz(*on);

         if (%parms > 2);
           direction_ = direction;
         endif;

         array.sortDirection = direction_;
         quickSort(array.data:array.size:ENTRY_SIZE:compareProcedure);

       end-proc;

    
       dcl-proc arraySortNumbers export;

         dcl-pi *n;
           arrayPtr pointer;
           direction ind const options(*nopass);
         end-pi;

         arraySort(arrayPtr:%paddr(compareNumbers):direction);

       end-proc;

     
       dcl-proc arraySortStrings export;

         dcl-pi *n;
           arrayPtr pointer;
           direction ind const options(*nopass);
         end-pi;

         arraySort(arrayPtr:%paddr(compareStrings):direction);

       end-proc;


       dcl-proc arrayTrimToSize export;

         dcl-pi *n;
           arrayPtr pointer const;
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);
         dcl-s allocatedSize uns(10) inz;

         if (array.size = 0);
           deallocSpace(array.data);
         else;
           allocSpace(array.data:ENTRY_SIZE * array.size);
         endif;

         array.allocatedSize = array.size;

       end-proc;

 
       dcl-proc arrayClear export;

         dcl-pi *n;
           arrayPtr pointer const;
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s entryPtr pointer inz(*null);
         dcl-s i uns(10) inz;

         for i = 1 to array.size;
           disposeEntryObject(arrayPtr:i);
         endfor;

         deallocSpace(array.data);
         array.size = 0;
         array.allocatedSize = 0;

       end-proc;

 
       dcl-proc arraySize export;

         dcl-pi *n uns(10);
           arrayPtr pointer const;
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);

         return array.size;

       end-proc;

       dcl-proc arrayIsEmpty export;

         dcl-pi *n ind;
           arrayPtr pointer const;
         end-pi;

         return arraySize(arrayPtr) = 0;

       end-proc;


       dcl-proc arraySet export;

         dcl-pi *n;
           arrayPtr pointer;
           objectPtr pointer const;
           objectSize uns(10) const;
           index uns(10) const;
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s entryPtr pointer inz(*null);

         entryPtr = getEntry(arrayPtr:index);
         allocSpace(entry.objectPtr:objectSize);
         memcpy(entry.objectPtr:objectPtr:objectSize);

       end-proc;

  
       dcl-proc arraySetNumber export;

         dcl-pi *n;
           arrayPtr pointer;
           numberObject packed(22:7) value;
           index uns(10) const;
         end-pi;

         arraySet(arrayPtr:%addr(numberObject):%size(numberObject):index);

       end-proc;

  
       dcl-proc arraySetString export;

         dcl-pi *n;
           arrayPtr pointer;
           stringObject varchar(32767) value;
           index uns(10) const;
         end-pi;

         arraySet(arrayPtr:%addr(stringObject):%size(stringObject):index);

       end-proc;


       dcl-proc arrayRemove export;

         dcl-pi *n;
           arrayPtr pointer;
           index uns(10) const;
           toIndex uns(10) const options(*nopass);
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);
         dcl-s toIndex_ uns(10) inz;
         dcl-s positions int(10) inz;

         if (%parms > 2);
           toIndex_ = toIndex;
         else;
           toIndex_ = index;
         endif;

         positions = %int(index) - %int(toIndex_) - 1;
         moveEntries(arrayPtr:toIndex_ + 1:positions);
         array.size += positions;

       end-proc;


       dcl-proc arrayAddAll export;

         dcl-pi *n;
           arrayPtr pointer;
           fromArrayPtr pointer const;
           index uns(10) const options(*nopass);
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);
         dcl-ds fromArray likeds(arrayTpl) based(fromArrayPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s entryPtr pointer inz(*null);
         dcl-s i uns(10) inz;

         if (%parms > 2);
           for i = fromArray.size downto 1;
             entryPtr = getEntry(fromArrayPtr:i);
             arrayAdd(arrayPtr:entry.objectPtr:entry.objectSize:index);
           endfor;
         else;
           for i = 1 to fromArray.size;
             entryPtr = getEntry(fromArrayPtr:i);
             arrayAdd(arrayPtr:entry.objectPtr:entry.objectSize);
           endfor;
         endif;

       end-proc;


       dcl-proc arrayAdd export;

         dcl-pi *n;
           arrayPtr pointer;
           objectPtr pointer const;
           objectSize uns(10) const;
           index uns(10) const options(*nopass);
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s entryPtr pointer inz(*null);
         dcl-s index_ uns(10) inz;
         dcl-s newSize uns(10) inz;

         newSize = array.size + 1;

    
         ensureCapacity(arrayPtr:newSize);

         if (%parms > 3);
           index_ = index;
         else;
           index_ = newSize;
         endif;

         if (index_ < newSize);
           moveEntries(arrayPtr:index_:1);
         endif;

       
         entryPtr = getEntry(arrayPtr:index_);
         allocSpace(entry.objectPtr:objectSize);
         memcpy(entry.objectPtr:objectPtr:objectSize);
         entry.objectSize = objectSize;
         entry.parentPtr = arrayPtr;

         array.size = newSize;

       end-proc;

  
       dcl-proc arrayAddNumber export;

         dcl-pi *n;
           arrayPtr pointer;
           numberObject packed(22:7) value;
           index uns(10) const options(*nopass);
         end-pi;

         if (%parms > 2);
           arrayAdd(arrayPtr:%addr(numberObject):%size(numberObject):index);
         else;
           arrayAdd(arrayPtr:%addr(numberObject):%size(numberObject));
         endif;

       end-proc;

 
       dcl-proc arrayAddString export;

         dcl-pi *n;
           arrayPtr pointer;
           stringObject varchar(32767) value;
           index uns(10) const options(*nopass);
         end-pi;

         if (%parms > 2);
           arrayAdd(
              arrayPtr:
              %addr(stringObject:*data):
              %len(stringObject):
              index
           );
         else;
           arrayAdd(arrayPtr:%addr(stringObject:*data):%len(stringObject));
         endif;

       end-proc;


       dcl-proc arrayGet export;

         dcl-pi *n pointer;
           arrayPtr pointer const;
           index uns(10) const;
         end-pi;

         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s entryPtr pointer inz(*null);

         entryPtr = getEntry(arrayPtr:index);

         return entry.objectPtr;

       end-proc;


       dcl-proc arrayGetNumber export;

         dcl-pi *n packed(22:7);
           arrayPtr pointer const;
           index uns(10) const;
         end-pi;

         dcl-s object packed(22:7) based(objectPtr);
         dcl-s objectPtr pointer inz(*null);

         objectPtr = arrayGet(arrayPtr:index);

         return object;

       end-proc;

       dcl-proc arrayGetString export;

         dcl-pi *n varchar(32767);
           arrayPtr pointer const;
           index uns(10) const;
         end-pi;

         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s entryPtr pointer inz(*null);

         entryPtr = getEntry(arrayPtr:index);

         return %str(entry.objectPtr:entry.objectSize);

       end-proc;


       dcl-proc getEntry;

         dcl-pi *n pointer;
           arrayPtr pointer const;
           index uns(10) const;
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);

         return array.data + (ENTRY_SIZE * (index - 1));

       end-proc;

    
       dcl-proc disposeEntryObject;

         dcl-pi *n;
           arrayPtr pointer const;
           index uns(10) const;
         end-pi;

         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s entryPtr pointer inz(*null);

         entryPtr = getEntry(arrayPtr:index);

         if (entry.objectPtr <> *null);
           deallocSpace(entry.objectPtr);
         endif;

       end-proc;

       dcl-proc moveEntries;

         dcl-pi *n;
           arrayPtr pointer;
           startIndex uns(10) const;
           positions int(10) const;
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s entryPtr pointer inz(*null);
         dcl-s tempPtr pointer inz(*null);
         dcl-s destinationIndex int(10) inz;
         dcl-s bytesToCopy uns(10) inz;
         dcl-s i uns(10) inz;

     
         destinationIndex = startIndex + positions;

         select;
           when (positions < 0);
       
             for i = destinationIndex to startIndex - 1;
               disposeEntryObject(arrayPtr:i);
             endfor;

             if (startIndex > array.size);
               
               return;
             else;
             
               exsr copyBytes;
             endif;

          
             for i = array.size downto array.size + positions + 1;
               entryPtr = getEntry(arrayPtr:i);
               entry.objectPtr = *null;
             endfor;
           when (positions > 0);
           
             exsr copyBytes;

           
             for i = startIndex to destinationIndex - 1;
               entryPtr = getEntry(arrayPtr:i);
               entry.objectPtr = *null;
             endfor;
           other;
         endsl;

     
         begsr copyBytes;

           bytesToCopy = ENTRY_SIZE * (array.size - startIndex + 1);

     
           allocSpace(tempPtr:bytesToCopy);
           memcpy(tempPtr:getEntry(arrayPtr:startIndex):bytesToCopy);

      
           memcpy(
              getEntry(arrayPtr:destinationIndex):
              tempPtr:
              bytesToCopy
           );

           deallocSpace(tempPtr);

         endsr;

       end-proc;

       dcl-proc ensureCapacity;

         dcl-pi *n;
           arrayPtr pointer;
           elements uns(10) const;
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);
         dcl-s allocatedSize int(10) inz;

         allocatedSize = array.allocatedSize;

         if (elements <= allocatedSize);
           return;
         endif;

         dow (allocatedSize - elements < 0);
           allocatedSize += (allocatedSize / 2 * (1 + array.modCount / 10)) + 1;
           array.modCount += 1;
         enddo;

         array.allocatedSize = allocatedSize;
         allocSpace(array.data:ENTRY_SIZE * allocatedSize);

       end-proc;

     
       dcl-proc compareNumbers;

         dcl-pi *n int(10);
           element1 likeds(entryTpl) const;
           element2 likeds(entryTpl) const;
         end-pi;

         dcl-ds array likeds(arrayTpl) based(element1.parentPtr);
         dcl-s number1 packed(22:7) based(element1.objectPtr);
         dcl-s number2 packed(22:7) based(element2.objectPtr);
         dcl-s result int(3) inz;

         if (number1 > number2);
           result = 1;
         elseif (number1 < number2);
           result = -1;
         endif;

         return getSortResult(result:array.sortDirection);

       end-proc;

 
       dcl-proc compareStrings;

         dcl-pi *n int(10);
           element1 likeds(entryTpl) const;
           element2 likeds(entryTpl) const;
         end-pi;

         dcl-ds array likeds(arrayTpl) based(element1.parentPtr);
         dcl-s string1 varchar(32767) inz;
         dcl-s string2 varchar(32767) inz;
         dcl-s result int(3) inz;

         string1 = %str(element1.objectPtr:element1.objectSize);
         string2 = %str(element2.objectPtr:element2.objectSize);

         if (string1 > string2);
           result = 1;
         elseif (string1 < string2);
           result = -1;
         endif;

         return getSortResult(result:array.sortDirection);

       end-proc;


       dcl-proc getSortResult;

         dcl-pi *n int(3);
           result int(3) const;
           direction ind const;
         end-pi;

         if (direction);
           return result;
         else;
           return -result;
         endif;

       end-proc;

       dcl-proc rangeCheck;

         dcl-pi *n;
           arrayPtr pointer const;
           index uns(10) const;
         end-pi;

         dcl-ds array likeds(arrayTpl) based(arrayPtr);

         if (index < 1 or index > array.size + 1);
           throwError(
              'CPF9999':
              '*ESCAPE':
              'Index out of bounds exception: ' + %char(index)
           );
         endif;

       end-proc;

 
       dcl-proc throwError;

         dcl-pi *n;
           messageId char(7) const;
           messageType char(10) const;
           messageText char(250) const options(*varsize);
         end-pi;

         dcl-pr error extpgm('QMHSNDPM');
           messageId char(7) const;
           messageFile char(20) const;
           messageData char(32767) const options(*varsize);
           messageDataLength int(10) const;
           messageType char(10) const;
           stackEntry char(10) const;
           stackCount int(10) const;
           messageKey char(4);
           errorDs char(32767) options(*varsize);
         end-pr;

         dcl-ds errorDs qualified inz;
           bytesProvided int(10);
           bytesAvailable int(10);
         end-ds;

         dcl-s messageKey char(4) inz;

         error(
            messageId:
            'QCPFMSG   *LIBL':
            %trim(messageText):
            %len(%trim(messageText)):
            messageType:
            '*':
            0:
            messageKey:
            errorDs
         );

       end-proc;

