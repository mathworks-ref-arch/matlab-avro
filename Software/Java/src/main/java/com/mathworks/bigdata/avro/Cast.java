/**
 *
 * Copyright (c) 2017, The MathWorks, Inc.
 */

package com.mathworks.bigdata.avro;

public class Cast {

	public static double[] convertToDouble(java.util.stream.Stream<Double> stream) {
		return stream.mapToDouble(f -> f).toArray();
	}

	public static int[] convertToInt(java.util.stream.Stream<Integer> stream) {
		return stream.mapToInt(f -> f).toArray();
	}	
}
