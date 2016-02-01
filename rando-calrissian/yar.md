# Library upgrades

* Start up a new Domain with your new library versions
  * this will be automated, of course
* Agree to policies which grant the new domain authority when both domains agree an object is identical between them
* Ask the new domain to adopt the old domain's objects
* Resolve conflicts
* When all objects are officially on the new domain, shut down the old Domain

# No differenence between proxy and migrated object

* A remote proxy is actually a halfway step towards the remote domain taking ownership of the object
* There are two name spaces for objects
  * Engine-level: oid@engine-id
  * world-level: globally unique ID, look into distributed hash tables
