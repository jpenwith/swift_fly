Media server that does on-the-fly conversion/transcoding. Built with [Vapor](https://github.com/vapor/vapor) and [MediaToolSwift](https://github.com/starkdmi/MediaToolSwift)

Run
```
swift run swift_fly serve
```

Then make requests, e.g. Resize https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Anatomy_of_a_Sunset-2.jpg/2880px-Anatomy_of_a_Sunset-2.jpg to fit 100x100
```
curl http://localhost:8080/image?output%5Bsize%5D=100,100&output%5Buti%5D%5Bidentifier%5D=public.jpeg&input%5Burl%5D=https%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fcommons%2Fthumb%2Fa%2Fa4%2FAnatomy_of_a_Sunset-2.jpg%2F2880px-Anatomy_of_a_Sunset-2.jpg
```
