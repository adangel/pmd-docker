# PMD Docker

Provides [PMD](https://pmd.github.io) packaged in a Docker image ready to use. It uses the alpine linux
flavor of [Eclipse Temurin](https://hub.docker.com/_/eclipse-temurin) as the basis.

* **Maintained by:** [PMD](https://github.com/pmd/docker)
* **Dockerfile:** https://github.com/pmd/docker/blob/main/Dockerfile

## Quickstart

```
docker run --rm --tty -v $PWD:/src pmdcode/pmd:latest check -d . -R rulesets/java/quickstart.xml
```

## How to use this image

### Verify it works

This just displays the PMD version.

```
docker run --rm --tty pmdcode/pmd:latest --version
```

### Only using default rulesets

In order to give access to the source code being analyzed, bind-mount the project source folder
using `-v /path/to/project:/project`:

```
docker run --rm --tty -v /path/to/project:/project pmdcode/pmd:latest \
    check -d /project/src/main/java -R rulesets/java/quickstart.xml
```

### Writing XML report into a file

Since the bind-mount has write-access by default, you can use it as the output destination for a report file in XML format:

```
docker run --rm --tty -v /path/to/project:/project pmdcode/pmd:latest \
    check -d /project/src/main/java -R rulesets/java/quickstart.xml -r /project/target/pmd-report.xml -f xml
```

### Use custom rulesets / rules

If you use a custom ruleset or rule, you need to add this onto PMD's runtime classpath. By default, the container
will pick-up any jar file that is in the folder `/custom-pmd-libs`. That means, you just need to add another
bind-mount for this:

```
docker run --rm --tty -v /path/to/project:/project -v /path/to/custom-rule-jars:/custom-pmd-libs \
    pmdcode/pmd:latest check -d /project/src/main/java -R rulesets/java/quickstart.xml
```

## How to build the docker image

```
PMD_VERSION=7.12.0; \
export PMD_VERSION; \
docker build --load \
    --no-cache \
    --progress=plain \
    --build-arg PMD_VERSION=$PMD_VERSION \
    --tag pmdcode/pmd:$PMD_VERSION \
    --tag pmdcode/pmd:latest \
    - < Dockerfile
```

