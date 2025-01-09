      
       ctl-opt nomain option(*srcstmt) bnddir('QC2LE':'UTILS');

       dcl-c HASHMAP_SIZE %size(hashMapTpl);
       dcl-c BUCKET_SIZE %size(bucketTpl);
       dcl-c ENTRY_SIZE %size(entryTpl);
       dcl-c LOAD_FACTOR 0.72;

      /include qcopysrc,memcpy
      /include qcopysrc,memcmp
      /include qcopysrc,utils

       dcl-ds hashMapTpl qualified template;
         bucketsPtr pointer;
         size uns(10);
         allocatedSize uns(10);
         loadFactor packed(3:2);
         threshold uns(10);
       end-ds;

       dcl-ds bucketTpl qualified template align;
         entryPtr pointer;
       end-ds;

       dcl-ds entryTpl qualified template align;
         nextEntryPtr pointer;
         keyPtr pointer;
         keySize uns(10);
         valuePtr pointer;
         valueSize uns(10);
         hashCode zoned(63);
         *n char(9);
       end-ds;


       dcl-proc hashMapNew export;

         dcl-pi *n pointer;
           initialSize uns(10) const;
           loadFactor packed(3:2) const options(*nopass);
         end-pi;

         dcl-ds hashMap likeds(hashMapTpl) based(hashMapPtr);
         dcl-ds bucket likeds(bucketTpl) based(bucketPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s hashMapPtr pointer inz(*null);
         dcl-s bucketPtr pointer inz(*null);
         dcl-s entryPtr pointer inz(*null);
         dcl-s loadFactor_ packed(3:2) inz;
         dcl-s i uns(10) inz;

         if (%parms > 1);
           loadFactor_ = loadFactor;
         else;
           loadFactor_ = LOAD_FACTOR;
         endif;

         allocSpace(hashMapPtr:HASHMAP_SIZE);
         hashMap.size = 0;
         hashMap.allocatedSize = getNearestExpOf2(initialSize);
         hashMap.loadFactor = loadFactor_;
         hashMap.threshold = loadFactor_ * hashMap.allocatedSize;
         allocSpace(hashMap.bucketsPtr:BUCKET_SIZE * hashMap.allocatedSize);

         return hashMapPtr;

       end-proc;

   
       dcl-proc hashMapDispose export;

         dcl-pi *n;
           hashMapPtr pointer;
         end-pi;

         dcl-ds hashMap likeds(hashMapTpl) based(hashMapPtr);

         if (hashMapPtr <> *null);
           hashMapClear(hashMapPtr);
           deallocSpace(hashMapPtr);
         endif;

       end-proc;

  
       dcl-proc hashMapClear export;

         dcl-pi *n;
           hashMapPtr pointer const;
         end-pi;

         dcl-ds hashMap likeds(hashMapTpl) based(hashMapPtr);
         dcl-ds bucket likeds(bucketTpl) based(bucketPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s bucketPtr pointer inz(*null);
         dcl-s entryPtr pointer inz(*null);
         dcl-s tempPtr pointer inz(*null);
         dcl-s i uns(10) inz;

         for i = 1 to hashMap.allocatedSize;
           bucketPtr = getBucket(hashMap.bucketsPtr:i);
           entryPtr = bucket.entryPtr;

           dow (entryPtr <> *null);
             tempPtr = entry.nextEntryPtr;
             disposeEntry(entryPtr);
             entryPtr = tempPtr;
           enddo;

           bucket.entryPtr = *null;
         endfor;

         hashMap.size = 0;

       end-proc;

   
       dcl-proc hashMapSize export;

         dcl-pi *n uns(10);
           hashMapPtr pointer const;
         end-pi;

         dcl-ds hashMap likeds(hashMapTpl) based(hashMapPtr);

         return hashMap.size;

       end-proc;

  
       dcl-proc hashMapPut export;

         dcl-pi *n;
           hashMapPtr pointer const;
           keyPtr pointer const;
           keySize uns(10) const;
           valuePtr pointer const;
           valueSize uns(10) const;
         end-pi;

         dcl-ds hashMap likeds(hashMapTpl) based(hashMapPtr);

         hashMap.size += 1;
         ensureCapacity(hashMapPtr:hashMap.size);
         addEntry(
            hashMap.bucketsPtr:
            hashMap.allocatedSize:
            getHashCode(keyPtr:keySize):
            keyPtr:
            keySize:
            valuePtr:
            valueSize
         );

       end-proc;

   
       dcl-proc hashMapPutSS export;

         dcl-pi *n;
           hashMapPtr pointer const;
           stringKey varchar(32767) value;
           stringValue varchar(32767) value;
         end-pi;

         hashMapPut(
            hashMapPtr:
            %addr(stringKey:*data):%len(stringKey):
            %addr(stringValue:*data):%len(stringValue)
         );

       end-proc;

     
       dcl-proc hashMapPutNN export;

         dcl-pi *n;
           hashMapPtr pointer const;
           numericKey packed(22:7) value;
           numericValue packed(22:7) value;
         end-pi;

         hashMapPut(
            hashMapPtr:
            %addr(numericKey):%size(numericKey):
            %addr(numericValue):%size(numericValue)
         );

       end-proc;

   
       dcl-proc hashMapGet export;

         dcl-pi *n pointer;
           hashMapPtr pointer const;
           keyPtr pointer const;
           keySize uns(10) const;
         end-pi;

         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s entryPtr pointer inz(*null);

         entryPtr = hashMapGetEntry(hashMapPtr:keyPtr:keySize);

         if (entryPtr = *null);
           return *null;
         endif;

         return entry.valuePtr;

       end-proc;

    
       dcl-proc hashMapGetSS export;

         dcl-pi *n varchar(32767);
           hashMapPtr pointer const;
           key varchar(32767) value;
         end-pi;

         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s entryPtr pointer inz(*null);

         entryPtr = hashMapGetEntry(hashMapPtr:%addr(key:*data):%len(key));

         return %str(entry.valuePtr:entry.valueSize);

       end-proc;

    
       dcl-proc hashMapGetNN export;

         dcl-pi *n packed(22:7);
           hashMapPtr pointer const;
           key packed(22:7) value;
         end-pi;

         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s entryPtr pointer inz(*null);
         dcl-s packedValue packed(22:7) based(entry.valuePtr);

         entryPtr = hashMapGetEntry(hashMapPtr:%addr(key):%size(key));

         if (entryPtr = *null);
           return *loval;
         endif;

         return packedValue;

       end-proc;

       dcl-proc hashMapContainsKey export;

         dcl-pi *n ind;
           hashMapPtr pointer const;
           keyPtr pointer const;
           keySize uns(10) const;
         end-pi;

         return hashMapGet(hashMapPtr:keyPtr:keySize) <> *null;

       end-proc;

       dcl-proc hashMapContainsValue export;

         dcl-pi *n ind;
           hashMapPtr pointer const;
           valuePtr pointer const;
           valueSize uns(10) const;
         end-pi;

         dcl-ds hashMap likeds(hashMapTpl) based(hashMapPtr);
         dcl-ds bucket likeds(bucketTpl) based(bucketPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s bucketPtr pointer inz(*null);
         dcl-s entryPtr pointer inz(*null);
         dcl-s i uns(10) inz;

         for i = 1 to hashMap.allocatedSize;
           bucketPtr = getBucket(hashMap.bucketsPtr:i);
           entryPtr = bucket.entryPtr;

           dow (entryPtr <> *null);
             if (memcmp(entry.valuePtr:valuePtr:valueSize) = 0);
               return *on;
             endif;

             entryPtr = entry.nextEntryPtr;
           enddo;
         endfor;

         return *off;

       end-proc;

       dcl-proc hashMapRemove export;

         dcl-pi *n;
           hashMapPtr pointer const;
           keyPtr pointer const;
           keySize uns(10) const;
         end-pi;

         dcl-ds hashMap likeds(hashMapTpl) based(hashMapPtr);
         dcl-ds bucket likeds(bucketTpl) based(bucketPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s bucketPtr pointer inz(*null);
         dcl-s entryPtr pointer inz(*null);
         dcl-s hashCode zoned(63) inz;
         dcl-s bucketIndex uns(10) inz;

         hashCode = getHashCode(keyPtr:keySize);
         bucketIndex = getBucketIndex(hashCode:hashMap.allocatedSize);
         bucketPtr = getBucket(hashMap.bucketsPtr:bucketIndex);
         entryPtr = bucket.entryPtr;

         dow (entryPtr <> *null);
           if (entry.hashCode = hashCode);
             if (entryPtr = bucket.entryPtr);
               bucket.entryPtr = *null;
             endif;

             deallocSpace(entryPtr);
             hashMap.size -= 1;
             return;
           endif;

           entryPtr = entry.nextEntryPtr;
         enddo;

       end-proc;

       dcl-proc hashMapGetEntry;

         dcl-pi *n pointer;
           hashMapPtr pointer const;
           keyPtr pointer const;
           keySize uns(10) const;
         end-pi;

         dcl-ds hashMap likeds(hashMapTpl) based(hashMapPtr);
         dcl-ds bucket likeds(bucketTpl) based(bucketPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s hashCode zoned(63) inz;
         dcl-s bucketIndex uns(10) inz;
         dcl-s bucketPtr pointer inz(*null);
         dcl-s entryPtr pointer inz(*null);

         hashCode = getHashCode(keyPtr:keySize);
         bucketIndex = getBucketIndex(hashCode:hashMap.allocatedSize);
         bucketPtr = getBucket(hashMap.bucketsPtr:bucketIndex);
         entryPtr = bucket.entryPtr;

         dow (entryPtr <> *null);
           if (entry.hashCode = hashCode);
             return entryPtr;
           endif;

           entryPtr = entry.nextEntryPtr;
         enddo;

         return *null;

       end-proc;

       dcl-proc getHashCode;

         dcl-pi *n zoned(63);
           objectPtr pointer const;
           objectSize uns(10) const;
         end-pi;

         dcl-pr Qc3CalculateHash extproc('Qc3CalculateHash');
           inData pointer value;
           inDataSize int(10) const;
           inDataFormat char(8) const;
           algorithmDescription pointer value;
           algorithmFormat char(8) const;
           CryptographicServiceProvider char(1) const;
           CryptographicDeviceName char(10) const options(*omit);
           hash pointer value;
           apiError pointer value;
         end-pr;

         dcl-pr cvthc extproc('cvthc');
           target pointer value;
           source pointer value;
           sourceSize int(10) value;
         end-pr;

         dcl-pr cvtch extproc('cvtch');
           target pointer value;
           source pointer value;
           sourceSize int(10) value;
         end-pr;

         dcl-ds algd0500 qualified inz;
           hashingAlgorithm int(10) inz(HASH_SHA1);
         end-ds;

         dcl-ds apiError qualified inz;
           bytesProvided int(10);
           bytesAvailable int(10);
           exceptionId char(7);
           reserved char(1);
         end-ds;

         dcl-c HASH_MD5 1;
         dcl-c HASH_SHA1 2;
         dcl-c HASH_SHA256 3;
         dcl-c HASH_SHA384 4;
         dcl-c HASH_SHA512 5;
         dcl-c HEX_LENGTH %len(hex);
         dcl-c HEX_NUM_SIZE %size(hexNumber);

         dcl-s hash char(64) inz;
         dcl-s hex char(40) inz;
         dcl-s hexChar char(2) inz;
         dcl-s hexNumber int(3) inz;
         dcl-s integerValue zoned(63) inz;
         dcl-s incrementalValue zoned(63) inz;
         dcl-s i uns(3) inz;

         if (objectPtr = *null);
           return 1;
         endif;

         Qc3CalculateHash(
            objectPtr:
            objectSize:
            'DATA0100':
            %addr(algd0500):
            'ALGD0500':
            '0':
            *omit:
            %addr(hash):
            %addr(apiError)
         );

         cvthc(%addr(hex):%addr(hash):%len(hash) * 2);
         integerValue = 0;
         incrementalValue = 0;

         for i = HEX_LENGTH downto 1;
           hexChar = '0' + %subst(hex:HEX_LENGTH - i + 1:1);
           cvtch(%addr(hexNumber):%addr(hexChar):HEX_NUM_SIZE * 2);
           integerValue = (hexNumber * (16 ** (i - 1)));
           incrementalValue += integerValue;
         endfor;

         return incrementalValue;

       end-proc;

       dcl-proc getBucketIndex;

         dcl-pi *n uns(10);
           hashCode zoned(63) const;
           allocatedSize uns(10) const;
         end-pi;

         dcl-s index uns(10) inz;

         index = %rem(hashCode:allocatedSize);

         if (index = 0);
           index = 1;
         endif;

         return index;

       end-proc;

       dcl-proc getBucket;

         dcl-pi *n pointer;
           bucketsPtr pointer const;
           index uns(10) const;
         end-pi;

         return bucketsPtr + (BUCKET_SIZE * (index - 1));

       end-proc;

       dcl-proc getNearestExpOf2;

         dcl-pi *n uns(10);
           number uns(10) const;
         end-pi;

         dcl-s newNumber uns(10) inz(1);

         dow (newNumber < number);
           newNumber *= 2;
         enddo;

         return newNumber;

       end-proc;

       dcl-proc disposeEntry;

         dcl-pi *n;
           entryPtr pointer;
         end-pi;

         dcl-ds entry likeds(entryTpl) based(entryPtr);

         deallocSpace(entry.keyPtr);
         deallocSpace(entry.valuePtr);
         deallocSpace(entryPtr);

       end-proc;

       dcl-proc ensureCapacity;

         dcl-pi *n;
           hashMapPtr pointer const;
           size uns(10) const;
         end-pi;

         dcl-ds hashMap likeds(hashMapTpl) based(hashMapPtr);

         if (size > hashMap.threshold);
           hashMap.allocatedSize *= 2;
           allocSpace(hashMap.bucketsPtr:BUCKET_SIZE * hashMap.allocatedSize);
           hashMap.threshold = hashMap.allocatedSize * hashMap.loadFactor;
           rebuild(hashMapPtr);
         endif;

       end-proc;

       dcl-proc addEntry;

         dcl-pi *n;
           bucketsPtr pointer const;
           bucketsSize uns(10) const;
           hashCode zoned(63) const;
           keyPtr pointer const;
           keySize uns(10) const;
           valuePtr pointer const;
           valueSize uns(10) const;
         end-pi;

         dcl-ds bucket likeds(bucketTpl) based(bucketPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s bucketPtr pointer inz(*null);
         dcl-s entryPtr pointer inz(*null);
         dcl-s oldEntryPtr pointer inz(*null);
         dcl-s bucketIndex uns(10) inz;

         bucketIndex = getBucketIndex(hashCode:bucketsSize);
         bucketPtr = getBucket(bucketsPtr:bucketIndex);
         entryPtr = bucket.entryPtr;

         if (entryPtr = *null);
           allocSpace(entryPtr:ENTRY_SIZE);
           bucket.entryPtr = entryPtr;
         else;
           
           dow (entryPtr <> *null);
             if (entry.hashCode = hashCode);
               
               allocSpace(entry.valuePtr:valueSize);
               memcpy(entry.valuePtr:valuePtr:valueSize);
               entry.valueSize = valueSize;
               return;
             endif;

             if (entry.nextEntryPtr = *null);
               leave;
             endif;

             entryPtr = entry.nextEntryPtr;
           enddo;

           
           allocSpace(oldEntryPtr:ENTRY_SIZE);
           memcpy(oldEntryPtr:entryPtr:ENTRY_SIZE);
           entry.keyPtr = *null;
           entry.valuePtr = *null;
         endif;

         allocSpace(entry.keyPtr:keySize);
         allocSpace(entry.valuePtr:valueSize);
         memcpy(entry.keyPtr:keyPtr:keySize);
         memcpy(entry.valuePtr:valuePtr:valueSize);
         entry.nextEntryPtr = oldEntryPtr;
         entry.keySize = keySize;
         entry.valueSize = valueSize;
         entry.hashCode = hashCode;

       end-proc;

       dcl-proc rebuild;

         dcl-pi *n;
           hashMapPtr pointer const;
         end-pi;

         dcl-ds hashMap likeds(hashMapTpl) based(hashMapPtr);
         dcl-ds bucket likeds(bucketTpl) based(bucketPtr);
         dcl-ds entry likeds(entryTpl) based(entryPtr);
         dcl-s newBucketsPtr pointer inz(*null);
         dcl-s bucketPtr pointer inz(*null);
         dcl-s entryPtr pointer inz(*null);
         dcl-s i uns(10) inz;

       
         allocSpace(newBucketsPtr:BUCKET_SIZE * hashMap.allocatedSize);

         for i = 1 to %int(hashMap.allocatedSize / 2);
           bucketPtr = getBucket(hashMap.bucketsPtr:i);
           entryPtr = bucket.entryPtr;

           dow (entryPtr <> *null);
             addEntry(
                newBucketsPtr:
                hashMap.allocatedSize:
                entry.hashCode:
                entry.keyPtr:
                entry.keySize:
                entry.valuePtr:
                entry.valueSize
             );

             entryPtr = entry.nextEntryPtr;
           enddo;
         endfor;

         hashMapClear(hashMapPtr);
         deallocSpace(hashMap.bucketsPtr);
         hashMap.bucketsPtr = newBucketsPtr;

       end-proc;

