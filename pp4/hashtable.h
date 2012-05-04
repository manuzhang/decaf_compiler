/* File: hashtable.h
 * -----------------
 * This is a simple table for storing values associated with a string
 * key, supporting simple operations for Enter and Lookup.  It is not
 * much more than a thin cover over the STL associative map container,
 * but hides the awkward C++ template syntax and provides a more
 * familiar interface.
 *
 * The keys are always strings, but the values can be of any type
 * (ok, that's actually kind of a fib, it expects the type to be
 * some sort of pointer to conform to using NULL for "not found").
 * The typename for a Hashtable includes the value type in angle
 * brackets, e.g.  if the table is storing  char *as values, you
 * would use the type name Hashtable<char*>. If storing values
 * that are of type Decl*, it would be Hashtable<Decl*>.
 * The same notation is used on the matching iterator for the table,
 * i.e. a Hashtable<char*> supports an Iterator<char*>.
 *
 * An iterator is provided for iterating over the entries in a table. 
 * The iterator walks through the values, one by one, in alphabetical
 * order by the key. Sample iteration usage:
 *
 *       void PrintNames(Hashtable<Decl*> *table)
 *       {
 *          Iterator<Decl*> iter = table->GetIterator();
 *          Decl *decl;
 *          while ((decl = iter.GetNextValue()) != NULL) {
 *               printf("%s\n", decl->GetName());
 *          }
 *       }
 */

#ifndef _H_hashtable
#define _H_hashtable

#include <map>
#include <string.h>
using namespace std;
    
struct ltstr {
  bool operator()(const char* s1, const char* s2) const
  { return strcmp(s1, s2) < 0; }
};


template <class Value> class Iterator; 
 
template<class Value> class Hashtable {

  private: 
     multimap<const char*, Value, ltstr> mmap;
 
   public:
            // ctor creates a new empty hashtable
     Hashtable() {}

           // Returns number of entries currently in table
     int NumEntries() const;

           // Associates value with key. If a previous entry for
           // key exists, the bool parameter controls whether 
           // new value overwrites the previous (removing it from
           // from the table entirely) or just shadows it (keeps previous
           // and adds additional entry). The lastmost entered one for an
           // key will be the one returned by Lookup.
     void Enter(const char *key, Value value,
		    bool overwriteInsteadOfShadow = true);

           // Removes a given key->value pair.  Any other values
           // for that key are not affected. If this is the last
           // remaining value for that key, the key is removed
           // entirely.
     void Remove(const char *key, Value value);

          // Returns value stored under key or NULL if no match.
          // If more than one value for key (ie shadow feature was
          // used during Enter), returns the lastmost entered one.
     Value Lookup(const char *key);

          // Returns an Iterator object (see below) that can be used to
          // visit each value in the table in alphabetical order.
     Iterator<Value> GetIterator();

};


/* Don't worry too much about how the Iterator is implemented, see
 * sample usage above for how to iterate over a hashtable using an
 * iterator.
 */
template <class Value> 
class Iterator {

  friend class Hashtable<Value>;

  private:
    typename multimap<const char*, Value , ltstr>::iterator cur, end;
    Iterator(multimap<const char*, Value, ltstr>& t)
	: cur(t.begin()), end(t.end()) {}
	 
  public:
         // Returns current value and advances iterator to next.
         // Returns NULL when there are no more values in table
         // Visits every value, even those that are shadowed.
    Value GetNextValue();
};


#include "hashtable.cc" // icky, but allows implicit template instantiation

#endif

