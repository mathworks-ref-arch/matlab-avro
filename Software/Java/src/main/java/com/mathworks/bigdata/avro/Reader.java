/**
 *
 * Copyright (c) 2017, The MathWorks, Inc.
 */

package com.mathworks.bigdata.avro;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.avro.Schema;
import org.apache.avro.Schema.Field;
import org.apache.avro.Schema.Type;
import org.apache.avro.file.DataFileReader;
import org.apache.avro.file.DataFileStream.Header;
import org.apache.avro.file.SeekableInput;
import org.apache.avro.file.SeekableFileInput;
import org.apache.avro.generic.GenericArray;
import org.apache.avro.generic.GenericDatumReader;
import org.apache.avro.generic.GenericRecord;
import org.apache.avro.io.DatumReader;
import org.apache.hadoop.conf.Configuration;
import org.apache.avro.mapred.FsInput;

/**
 * The Class Reader.
 */
public class Reader {

	/** The array count. */
	private Object[] arrayCount;

	/** The data container. */
	private List<Object> dataContainer = new ArrayList<>();

	/** The data file reader. */
	DataFileReader<GenericRecord> dataFileReader = null;

	/** The field names. */
	private List<String> fieldNames;

	/** The is data array. */
	private List<Object> isDataArray = new ArrayList<>();

	/** The seek file. */
	SeekableInput seekFile = null;

	/** The use sync to seek. */
	boolean useSyncToSeek = false;

	/**
	 * Cast field data.
	 *
	 * @param data     the data
	 * @param arrayInd the array ind
	 * @param value    the value
	 * @param schema   the schema
	 * @param isArray  the is array
	 */
	@SuppressWarnings("unchecked")
	private void castFieldData(Object data, Object arrayInd, Object value, Schema schema, boolean isArray) {

		switch (schema.getType()) {
		case BOOLEAN:
			if (!isArray)
				((List<Boolean>) data).add((Boolean) value);
			else {
				((List<Boolean>) data).addAll((GenericArray<Boolean>) value);
				((List<Integer>) arrayInd).add(((GenericArray<Boolean>) value).size());
			}
			break;
		case INT:
			if (!isArray)
				((List<Integer>) data).add((Integer) value);
			else {
				((List<Integer>) data).addAll((GenericArray<Integer>) value);
				((List<Integer>) arrayInd).add(((GenericArray<Integer>) value).size());
			}
			break;
		case LONG:
			if (!isArray)
				((List<Long>) data).add((Long) value);
			else {
				((List<Long>) data).addAll((GenericArray<Long>) value);
				((List<Integer>) arrayInd).add(((GenericArray<Long>) value).size());
			}
			break;
		case FLOAT:
			if (!isArray)
				((List<Float>) data).add((Float) value);
			else {
				((List<Float>) data).addAll((GenericArray<Float>) value);
				((List<Integer>) arrayInd).add(((GenericArray<Float>) value).size());
			}
			break;
		case DOUBLE:
			if (!isArray)
				((List<Double>) data).add((Double) value);
			else {
				((List<Double>) data).addAll((GenericArray<Double>) value);
				((List<Integer>) arrayInd).add(((GenericArray<Double>) value).size());
			}
			break;
		case BYTES:
			if (!isArray)
				((List<Byte[]>) data).add((Byte[]) value);
			else {
				((List<Byte[]>) data).addAll((GenericArray<Byte[]>) value);
				((List<Integer>) arrayInd).add(((GenericArray<Byte[]>) value).size());
			}
			break;
		case STRING:
			if (!isArray)
				((List<String>) data).add(value.toString());
			else {
				((List<String>) data).addAll((GenericArray<String>) value);
				((List<Integer>) arrayInd).add(((GenericArray<String>) value).size());
			}
			break;
		case ARRAY:
			castFieldData(data, arrayInd, value, schema.getElementType(), true);
		default:
		}
	}

	/**
	 * Cast to matlab.
	 *
	 * @param data  the data
	 * @param types the types
	 */
	@SuppressWarnings("unchecked")
	private void castToMatlab(Object[] data, List<Type> types) {

		int i = 0;
		for (Type type : types) {
			int j = 0;
			switch (type) {
			case BOOLEAN:
				boolean[] retbool = new boolean[((List<Boolean>) data[i]).size()];
				for (Boolean v : (List<Boolean>) data[i]) {
					retbool[j++] = v != null ? (boolean) v : Boolean.FALSE;
				}
				data[i] = retbool;
				break;
			case DOUBLE:
				data[i] = ((List<Double>) data[i]).stream().mapToDouble(x -> x).toArray();
				break;
			case FLOAT:
				float[] retfloat = new float[((List<Float>) data[i]).size()];
				for (Float v : (List<Float>) data[i]) {
					retfloat[j++] = v != null ? (float) v : Float.MAX_VALUE;
				}
				data[i] = retfloat;
				break;
			case INT:
				data[i] = ((List<Integer>) data[i]).stream().mapToInt(x -> x).toArray();
				break;
			case LONG:
				data[i] = ((List<Long>) data[i]).stream().mapToLong(x -> x).toArray();
				break;
			case STRING:
				data[i] = ((List<String>) data[i]).toArray(new String[0]);
				break;
			default:
			}
			i++;
		}
	}

	private void castArrayIndex() {

		for (int i = 0; i < this.arrayCount.length; i++) {
			this.arrayCount[i] = this.arrayCount[i]!=null ?  ((List<Integer>) this.arrayCount[i]).stream().mapToInt(j -> j).toArray() : null;

		}
	}

	/**
	 * Gets the array count.
	 *
	 * @return the array count
	 */
	public Object[] getArrayCount() {
		return this.arrayCount;
	}

	/**
	 * Gets the data file reader.
	 *
	 * @return the data file reader
	 */
	public DataFileReader<GenericRecord> getDataFileReader() {
		return this.dataFileReader;
	}

	/**
	 * Gets the field names.
	 *
	 * @param schema the schema
	 * @return the field names
	 */
	private List<String> getFieldNames(Schema schema) {

		List<Field> fields = schema.getFields();
		List<String> names = new ArrayList<>();
		for (Field field : fields) {
			names.add(field.name());
		}
		return names;
	}

	/**
	 * Gets the meta.
	 *
	 * @param fileName the file name
	 * @return the meta
	 * @throws IOException Signals that an I/O exception has occurred.
	 */
	public Map<String, String> getMeta(String fileName) throws IOException {

		File file = new File(fileName);
		DatumReader<GenericRecord> datumReader = new GenericDatumReader<>();
		Map<String, String> map = new HashMap<>();

		try (DataFileReader<GenericRecord> dFileReader = new DataFileReader<>(file, datumReader)) {

			for (String key : dFileReader.getMetaKeys()) {
				map.put(key, dFileReader.getMetaString(key));
			}
		}
		return map;

	}

	/**
	 * Gets the schema.
	 *
	 * @param fileName the file name
	 * @return the schema
	 * @throws IOException Signals that an I/O exception has occurred.
	 */
	public String getSchema(String fileName) throws IOException {

		File file = new File(fileName);
		DatumReader<GenericRecord> datumReader = new GenericDatumReader<>();

		try (DataFileReader<GenericRecord> dFileReader = new DataFileReader<>(file, datumReader)) {
			Schema schema = dFileReader.getSchema();
			return schema.toString(true);
		}

	}

	/**
	 * Gets the types.
	 *
	 * @param schema the schema
	 * @return the types
	 */
	private List<Type> getTypes(Schema schema) {

		List<Field> fields = schema.getFields();
		List<Type> types = new ArrayList<>();

		for (Field field : fields) {
			switch (field.schema().getType()) {
			case UNION:
				List<Schema> schemas = field.schema().getTypes();
				for (Schema s : schemas) {
					if (s.getType() != Schema.Type.NULL) {
						types.add(s.getType());
						break;
					}
				}
				break;
			case ENUM:
				types.add(Schema.Type.STRING);
				break;
			case ARRAY:
				types.add(field.schema().getElementType().getType());
				break;
			case RECORD:
				getTypes(field.schema());
				break;
			default:
				types.add(field.schema().getType());
			}
		}
		return types;
	}

	/**
	 * Gets the variable names.
	 *
	 * @return the variable names
	 */
	public String[] getVariableNames() {
		return this.fieldNames.toArray(new String[0]);
	}

	/**
	 * Inits the field.
	 *
	 * @param type the type
	 * @return the object
	 */
	private Object initField(Type type) {
		Object out = null;
		switch (type) {
		case BOOLEAN:
			out = new ArrayList<Boolean>();
			break;
		case INT:
			out = new ArrayList<Integer>();
			break;
		case LONG:
			out = new ArrayList<Long>();
			break;
		case FLOAT:
			out = new ArrayList<Float>();
			break;
		case DOUBLE:
			out = new ArrayList<Double>();
			break;
		case BYTES:
			out = new ArrayList<Byte[]>();
			break;
		case STRING:
			out = new ArrayList<String>();
			break;
		default:
		}
		return out;
	}

	/**
	 * Initialize data new.
	 *
	 * @param schema the schema
	 */
	private void initializeDataNew(Schema schema) {

		List<Field> fields = schema.getFields();

		for (Field field : fields) {
			Type type = field.schema().getType();
			switch (type) {
			case UNION:
				List<Schema> schemas = field.schema().getTypes();
				for (Schema s : schemas) {
					if (s.getType() != Schema.Type.NULL) {
						this.dataContainer.add(initField(s.getType()));
						this.isDataArray.add(null);
						break;
					}
				}
				break;
			case ENUM:
				this.dataContainer.add(initField(Schema.Type.STRING));
				this.isDataArray.add(null);
				break;
			case ARRAY:
				this.dataContainer.add(initField(field.schema().getElementType().getType()));
				this.isDataArray.add(initField(Type.INT));
				break;
			case RECORD:
				initializeDataNew(field.schema());
				break;
			default:
				this.dataContainer.add(initField(type));
				this.isDataArray.add(null);
			}

		}
	}

	/**
	 * Inits the reader.
	 *
	 * @param fileName     the file name
	 * @param seekPosition the seek position
	 * @throws IOException Signals that an I/O exception has occurred.
	 */
	public void initReader(String fileName, long seekPosition) throws IOException {

		if (this.dataFileReader != null && this.dataFileReader.hasNext()) {
			if (this.useSyncToSeek && seekPosition >= 0)
				this.dataFileReader.sync(seekPosition);
			else if (seekPosition >= 0)
				this.dataFileReader.seek(seekPosition);
			return;
		}

		DatumReader<GenericRecord> datumReader = new GenericDatumReader<>();
		Header header;

    if (fileName.startsWith("hdfs://")) {
			Configuration conf = new Configuration();
			conf.set("fs.hdfs.impl", "org.apache.hadoop.hdfs.DistributedFileSystem");
			FsInput file = new FsInput(new org.apache.hadoop.fs.Path(fileName), conf);
			this.dataFileReader = new DataFileReader<>(file, datumReader);
			this.seekFile = new FsInput(new org.apache.hadoop.fs.Path(fileName), conf);

		} else {
			File file = new File(fileName);
			this.dataFileReader = new DataFileReader<>(file, datumReader);
			this.seekFile = new SeekableFileInput(file);
		}

		header = this.dataFileReader.getHeader();
		this.dataFileReader.close();

		seekPosition = seekPosition < 0 ? 0 : seekPosition;
		this.seekFile.seek(seekPosition);
		this.dataFileReader = DataFileReader.openReader(this.seekFile, datumReader, header, true);
	}

	/**
	 * Read.
	 *
	 * @param fileName     the file name
	 * @param seekPosition the seek position
	 * @param numRecords   the num records
	 * @return the object[]
	 * @throws IOException Signals that an I/O exception has occurred.
	 */
	public Object[] read(String fileName, long seekPosition, double numRecords) throws IOException {

		int count = 0;

		// Initialize the record reader
		initReader(fileName, seekPosition);

		// Schema for the file
		Schema schema = this.dataFileReader.getSchema();

		// Initialize our data for storing results
		initializeDataNew(schema);
		Object[] out = this.dataContainer.toArray(new Object[this.dataContainer.size()]);
		this.arrayCount = this.isDataArray.toArray(new Object[this.isDataArray.size()]);

		// Fields to iterate over record
		this.fieldNames = getFieldNames(schema);

		// Reuse the record
		GenericRecord record = null;

		// Iterate through records
		while (this.dataFileReader.hasNext() && count <= numRecords - 1) {
			record = this.dataFileReader.next();
			int i = 0;

			// Iterate through fields in record
			for (String fieldName : this.fieldNames) {
				// Process the data for this field
				castFieldData(out[i], this.arrayCount[i], record.get(fieldName), schema.getField(fieldName).schema(),
						false);
				i++;
			}
			count++;
		}

		// Cast results to useful format for MATLAB
		castToMatlab(out, getTypes(schema));

		castArrayIndex();

		// Close all streams if we requested all records
		if (numRecords == Double.POSITIVE_INFINITY) {
			this.dataFileReader.close();
			this.seekFile.close();
		}

		return out;
	}

	/**
	 * Sets the use sync to seek.
	 *
	 * @param useSyncToSeek the new use sync to seek
	 */
	public void setUseSyncToSeek(boolean useSyncToSeek) {
		this.useSyncToSeek = useSyncToSeek;
	}

}
