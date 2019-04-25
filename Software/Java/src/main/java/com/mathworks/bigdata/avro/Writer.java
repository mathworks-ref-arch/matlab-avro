/**
 *
 * Copyright (c) 2017, The MathWorks, Inc.
 */

package com.mathworks.bigdata.avro;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Array;
import org.apache.avro.Schema;
import org.apache.avro.file.CodecFactory;
import org.apache.avro.file.DataFileWriter;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericDatumWriter;
import org.apache.avro.generic.GenericRecord;
import org.apache.avro.io.DatumWriter;
import org.apache.hadoop.conf.Configuration;
import org.apache.avro.mapred.FsInput;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

/**
 * The Class Writer.
 */
public class Writer {

	/** The add sync marker. */
	private boolean addSyncMarker = false;

	/** The append to file. */
	private boolean appendToFile = false;

	/** The meta keys. */
	private String[] metaKeys = null;

	/** The meta value. */
	private String[] metaValue = null;

	/**
	 * Adds the compression.
	 *
	 * @param fileWriter       the file writer
	 * @param compression      the compression
	 * @param compressionLevel the compression level
	 */
	public void addCompression(DataFileWriter<GenericRecord> fileWriter, String compression, int compressionLevel) {

		CodecFactory codec = CodecFactory.snappyCodec();

		switch (compression.toLowerCase()) {
		case "snappy":
			codec = CodecFactory.snappyCodec();
			break;
		case "none":
			codec = CodecFactory.nullCodec();
			break;
		case "deflate":
			codec = CodecFactory.deflateCodec(compressionLevel);
			break;
		case "xz":
			codec = CodecFactory.xzCodec(compressionLevel);
			break;
		case "bzip2":
			codec = CodecFactory.bzip2Codec();
			break;
		default:
		}

		fileWriter.setCodec(codec);
	}

	/**
	 * Adds the meta data.
	 *
	 * @param dataFileWriter the data file writer
	 * @param metaKeys       the meta keys
	 * @param metaValue      the meta value
	 */
	private void addMetaData(DataFileWriter<GenericRecord> dataFileWriter, String[] metaKeys, String[] metaValue) {

		if (metaKeys == null)
			return;

		int i = 0;
		for (String key : metaKeys) {
			dataFileWriter.setMeta(key, metaValue[i++]);
		}
	}

	/**
	 * Gets the object array.
	 *
	 * @param keyData the key data
	 * @return the object array
	 */
	private Object[] getObjectArray(Object keyData) {

		Object[] obj = null;

		if (keyData instanceof Object[])
			return (Object[]) keyData;
		else if (keyData.getClass().isArray()) {
			// If passed primitive arrays from MATLAB, we need to cast to an Object[]
			int num = Array.getLength(keyData);
			obj = new Object[num];
			for (int i = 0; i < num; ++i) {
				obj[i] = Array.get(keyData, i);
			}
		} else {
			obj = new Object[1];
			obj[0] = keyData;
		}
		return obj;
	}

	/**
	 * Sets the adds the sync marker.
	 *
	 * @param addSyncMarker the new adds the sync marker
	 */
	public void setAddSyncMarker(boolean addSyncMarker) {
		this.addSyncMarker = addSyncMarker;
	}

	/**
	 * Sets the append to file.
	 *
	 * @param appendData the new append to file
	 */
	public void setAppendToFile(boolean appendData) {
		this.appendToFile = appendData;
	}

	/**
	 * Sets the meta keys.
	 *
	 * @param metaKeys the new meta keys
	 */
	public void setMetaKeys(String[] metaKeys) {
		this.metaKeys = metaKeys;
	}

	/**
	 * Sets the meta value.
	 *
	 * @param metaValue the new meta value
	 */
	public void setMetaValue(String[] metaValue) {
		this.metaValue = metaValue;
	}

	public FSDataOutputStream getHDFSfile(String fileName) throws IOException {
		Configuration conf = new Configuration();
		conf.set("fs.hdfs.impl", "org.apache.hadoop.hdfs.DistributedFileSystem");
		FileSystem fs = FileSystem.get( java.net.URI.create(fileName), conf );
		FSDataOutputStream file = fs.create(new org.apache.hadoop.fs.Path(fileName));
		return file;
	}

	/**
	 * Write.
	 *
	 * @param fileName         the file name
	 * @param keys             the keys
	 * @param data             the data
	 * @param schemaString     the schema string
	 * @param compressionCodec the compression codec
	 * @param compressionLevel the compression level
	 * @throws IOException Signals that an I/O exception has occurred.
	 */
	public void write(String fileName, String[] keys, Object[] data, String schemaString, String compressionCodec,
			int compressionLevel) throws IOException {

		File file = new File(fileName);
		Schema schema = new Schema.Parser().parse(schemaString);
		GenericRecord record = null;

		// Cast data arrays to Object arrays if necessary
		for (int i = 0; i < data.length; i++) {
			data[i] = getObjectArray(data[i]);
		}

		DatumWriter<GenericRecord> datumWriter = new GenericDatumWriter<>(schema);
		if (appendToFile)
			datumWriter.setSchema(schema);

		try (DataFileWriter<GenericRecord> dataFileWriter = new DataFileWriter<>(datumWriter)) {
			addCompression(dataFileWriter, compressionCodec, compressionLevel);
			addMetaData(dataFileWriter, metaKeys, metaValue);
			if (appendToFile)
				dataFileWriter.appendTo(file);
			else
				dataFileWriter.create(schema, file);

			int rows = ((Object[]) data[0]).length;

			for (int j = 0; j < rows; j++) {
				record = new GenericData.Record(schema);
				int i = 0;
				for (String key : keys) {
					record.put(key, ((Object[]) data[i++])[j]);
				}
				dataFileWriter.append(record);
				if (addSyncMarker)
					dataFileWriter.flush();
			}
		}

	}
}
