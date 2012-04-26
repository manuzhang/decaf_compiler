/* File: hashtable.cc
 * ------------------
 * Implementation of Hashtable class.
 */
   

/* Hashtable::Enter
 * ----------------
 * Stores new value for given identifier. If the key already
 * has an entry and flag is to overwrite, will remove previous entry first,
 * otherwise it just adds another entry under same key. Copies the
 * key, so you don't have to worry about its allocation.
 */
template <class Value> 
void Hashtable<Value>::Enter(const char *key, Value val, bool overwrite)
{
  Value prev;
  if (overwrite && (prev = Lookup(key)))
    Remove(key, prev);
  mmap.insert(make_pair(strdup(key), val));
}

 
/* Hashtable::Remove
 * -----------------
 * Removes a given key-value pair from table. If no such pair, no
 * changes are made.  Does not affect any other entries under that key.
 */
template <class Value> void Hashtable<Value>::Remove(const char *key, Value val)
{
  if (mmap.count(key) == 0) // no matches at all
    return;

  typename multimap<const char *, Value>::iterator itr;
  itr = mmap.find(key); // start at first occurrence
  while (itr != mmap.upper_bound(key)) {
    if (itr->second == val) { // iterate to find matching pair
	mmap.erase(itr);
	break;
    }
    ++itr;
  }
} 

/* Hashtable::Lookup
 * -----------------
 * Returns the value earlier stored under key or NULL
 *if there is no matching entry
 */
template <class Value> 
Value Hashtable<Value>::Lookup(const char *key) 
{
  Value found = NULL;
  
  if (mmap.count(key) > 0) {
    typename multimap<const char *, Value>::iterator cur, last, prev;
    cur = mmap.find(key); // start at first occurrence
    last = mmap.upper_bound(key);
    while (cur != last) { // iterate to find last entered
	prev = cur; 
	if (++cur == mmap.upper_bound(key)) { // have to go one too far
	  found = prev->second; // one before last was it
	  break;
	}
    }
  }
  return found;
}


/* Hashtable::NumEntries
 * ---------------------
 */
template <class Value> 
int Hashtable<Value>::NumEntries() const
{
  return mmap.size();
}


/* Hashtable:GetIterator
 * ---------------------
 * Returns iterator which can be used to walk through all values in table.
 */
template <class Value> 
Iterator<Value> Hashtable<Value>::GetIterator() 
{
  return Iterator<Value>(mmap);
}


/* Iterator::GetNextValue
 * ----------------------
 * Iterator method used to return current value and advance iterator
 * to next entry. Returns null if no more values exist.
 */
template <class Value> 
Value Iterator<Value>::GetNextValue()
{
  return (cur == end ? NULL : (*cur++).second);
}


