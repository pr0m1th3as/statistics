## Copyright (C) 2006, 2008  Bill Denney  <bill@denney.ws>
##
## This software is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, write to the
## Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
## Boston, MA 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} linkage (@var{x})
## @deftypefnx {Function File} {@var{y} =} linkage (@var{x}, @var{method})
## Return clusters generated from a distance vector created by the pdist
## function.
##
## Methods can be:
##
## @table @samp
## @item "single" (default)
## Shortest distance between two clusters (aka a minimum spanning tree)
##
## @item "complete"
## Furthest distance between two clusters
##
## @item "average"
## Unweighted average distance (aka group average)
##
## @item "weighted"
## Weighted average distance
##
## @item "centroid"
## Centroid distance (not implemented)
##
## @item "median"
## Weighted center of mass distance
##
## @item "ward"
## Inner squared distance (minimum variance)
##
## @end table
##
## @var{x} is an ((m-1)*(m/2) x 1) distance vector as generated by
## pdist, and the output, @var{y} is an ((m - 1) x 3) vector defined
## with columns where the first and second columns are the cluster
## numbers of the two sub-clusters in the cluster, and the third column
## is the distance between those sub-clusters.  The sub-clusters are
## numbered where 1 to m are the input elements, and m+1 to the end are
## subsequently defined clusters.
## @seealso{cluster,pdist}
## @end deftypefn

## Author: Bill Denney <denney@...>

function y = linkage (x, method)

  ## check the input
  if (nargin < 1) || (nargin > 2)
    print_usage ();
  elseif (nargin < 2)
    method = "single";
  endif

  method = lower (method);
  if (isempty (x))
    error ("linkage: x cannot be empty");
  elseif (~ isvector (x))
    error ("linkage: x must be a vector");
  endif

  xmat = squareform (x);
  sxm = size(xmat, 1);

  if strcmp (method, "single")
    ## this is just a minimal spanning tree
    y = linker (xmat, @min);
  elseif strcmp (method, "complete")
    y = linker (xmat, @max);
  elseif strcmp (method, "average")
    error ("linkage: %s is not yet implemented", method);
  elseif strcmp (method, "weighted")
    error ("linkage: %s is not yet implemented", method);
  elseif strcmp (method, "centroid")
    error ("linkage: %s is not yet implemented", method);
  elseif strcmp (method, "median")
    y = linker (xmat, @median);
  elseif strcmp (method, "ward")
    error ("linkage: %s is not yet implemented", method);
  else
    error ("linkage: unrecognised method");
  endif
endfunction

function y = linker (matrix, findfxn)
  ## findfxn should return a scalar from a vector and a row from a
  ## matrix

  y = zeros (0,3);

  yidx = 0;
  startsize = size (matrix, 1);
  cnameidx = 1:startsize;
  while (~ isscalar (matrix))
    yidx++;
    sxm = size (matrix, 1);
    available = (tril (ones(sxm)) - eye (sxm));
    ## find the next link to make
    [r, c] = find (findfxn (matrix(logical (available))) == matrix, 1);

    ## update the results
    y(yidx, :) = [cnameidx(r) cnameidx(c) matrix(r, c)];
    ## update the indexes
    cnameidx(r) = yidx + startsize;
    cnameidx(c) = [];

    ## update the matrix (the diagonal element may be made inconsistent
    ## by this,but that doesn't really matter)
    matrix(r,:) = findfxn (matrix([r c], :));
    matrix(:,r) = matrix(r,:)';
    matrix(c,:) = [];
    matrix(:,c) = [];
  endwhile
endfunction