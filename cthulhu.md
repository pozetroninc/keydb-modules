# How to run 
1. Place your custom javascript in `/usr/lib/redis/modules`
2. Unload the cthulhu module from keydb cli 
    ```
        module unload cthulhu
    ```
3. Load the cthulhu module with your javascript
    ```
        module load /usr/lib/redis/modules/cthulhu.so /usr/lib/redis/modules/hello.js
    ```

# References
- https://github.com/sklivvz/cthulhu/blob/master/docs/intro.md
- https://github.com/sklivvz/cthulhu/blob/master/docs/build.md
