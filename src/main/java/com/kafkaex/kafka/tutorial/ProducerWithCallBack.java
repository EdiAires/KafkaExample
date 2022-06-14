package com.kafkaex.kafka.tutorial;

import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;

public class ProducerWithCallBack {
    public static void main(String[] args) {

        final Logger logger = LoggerFactory.getLogger(ProducerWithCallBack.class);



        // create producer properties
        Properties props = new Properties();
        props.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "127.0.0.1:9092");
        props.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        //create the producer <key,value>
        final KafkaProducer<String,String> producer = new KafkaProducer<String,String>(props);


        for (int i = 0; i < 10; i++) {

            // create producer record
            final ProducerRecord<String, String> record =
                    new ProducerRecord<String, String>("first_topic", "hello world " + Integer.toString(i));

            // send data - asynchronus
            producer.send(record, new Callback() {
                public void onCompletion(RecordMetadata recordMetadata, Exception e) {
                    // executes  every time a record is sucessfully sent or an exception is thrown
                    if(e == null)
                    {
                        // record was suessfully sent
                        logger.info("Received new metadata... \n" +
                                        "Topic: " + recordMetadata.topic() + "\n" +
                                        "Partition: " + recordMetadata.partition() + "\n" +
                                        "Offset: " + recordMetadata.offset() + "\n" +
                                        "Timestamp: " + recordMetadata.timestamp() );


                    } else{
                        //e.printStackTrace();
                        logger.error("Error while producing", e);

                    }
                }
            });

        }
        //flush data
        producer.flush();
        //flush data and close
         //producer.close();

    }
}
