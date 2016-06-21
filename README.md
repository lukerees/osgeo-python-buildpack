# Cloud Foundry OSGeo Python Buildpack
## (Fork of Python Buildpack)

This is based on the [Heroku buildpack](https://github.com/heroku/heroku-buildpack-python).

This buildpack supports running an application with the following additions:

* geospatial compile hook that bootstraps the following vendor and python additions
 * https://s3.amazonaws.com/boundlessps-public/cf/lib/vendor.tar.gz
    * GDAL 2.1.0
    * GEOS 3.5.0
    * PROJ.4 4.9.2
    * PostgreSQL Client 9.5.3
    * Mapnik 2.3.0
 * remote wheels
    * GDAL 2.1.0 python module
    * numpy 1.10.4 python module
    * pyproj 1.9.5.1 python module
 * https://s3.amazonaws.com/boundlessps-public/cf/lib/site-packages.tar.gz
    * cairo
    * mapnik
* geospatial.sh profile.d script
* required symlinks for GDAL, GEOS and PROJ libraries
* Upgraded Setuptools to 22.0.0
* Upgraded PIP to 8.1.2

## Usage

In order for this buildpack to bootstrap the additions above, a `cf` directory must exist with a `requirements.txt` file
GDAL, numpy and pyproj should not be an entry in `requirements.txt`, since this buildpack will add the required GDAL python modules via wheel install.

1. Use in Cloud Foundry

    Add the osgeo-python-buildpack entry in your manifest.yml

    Example:

    ```yml
    ---
    applications:
      - name: demo-geonode
    buildpack: https://github.com/boundlessgeo/osgeo-python-buildpack
    ```

__Note:__ Although the python buildpack is MIT-licensed, which is compatible with LGPL, the Cloud Foundry product as a whole is licensed under ASF, which is not compatible with LGPL. The custom OSGeo Python Buildpack was created from a fork of the python buildpack, which includes GEOS (licensed under the LGPL).
