# to make it easier to grab the neede package one-offs

class packages {
  if $kernel == "Linux" {
    include packages::shells
    include packages::archive
  }

}