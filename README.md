### 1. Where are structs, mappings, and arrays stored?

In Solidity, data can be stored in three main locations:

1.  Storage: permanent blockchain storage

2. Memory :temporary during function execution

3. Calldata: read-only function input data

Depending on how and where they are defined, structs, maps, and arrays have different storage locations. They can be stored in the persistent storage of the blockchain, temporary memory during function execution, or immutable calldata for function parameters.

### Structs

A struct is a custom data type and where it is stored depends on how it is used.

## In State variables
Stored in storage permanent on the blockchain and its elements are packed tightly in storage slots according to specific rules.

## Inside functions
Stored in memory and temporary, deleted after function ends

## call data
Structs can be passed to external functions via calldata

### Mappings
Mappings can only be stored in the contract's permanent storage as state variables.

## In State variables
Always stored in storage and is permanent. Cannot exist in memory and are used as state variables only
Mappings cannot be stored in memory or calldata directly.

### Arrays
The storage location for arrays depends on their type (static/dynamic) and declaration. They behave like structs

## State array
Stored in storage and are permanent

## In function
Stored in memory but temporary

## call data
Dynamic arrays can be used in calldata for external function calls. 