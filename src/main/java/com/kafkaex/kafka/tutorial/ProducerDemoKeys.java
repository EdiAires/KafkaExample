package com.kafkaex.kafka.tutorial;

import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.concurrent.ExecutionException;

public class ProducerDemoKeys {
    public static void main(String[] args) throws ExecutionException, InterruptedException {

        final Logger logger = LoggerFactory.getLogger(ProducerDemoKeys.class);



        // create producer properties
        Properties props = new Properties();
        props.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "127.0.0.1:9092");
        props.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        //create the producer <key,value>
        final KafkaProducer<String,String> producer = new KafkaProducer<String,String>(props);


        for (int i = 0; i < 10; i++) {

            // create producer record

            String topic = "first_topic";
            String value = "hello world " + Integer.toString(i);
            String key = "id_" + Integer.toString(i);

            final ProducerRecord<String, String> record =
                    new ProducerRecord<String, String>(topic,key,value);

            logger.info(("Key: " + key));

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
            }).get(); // block the .send() to make it synchronous - dont do this in prodution

        }
        //flush data
        producer.flush();
        //flush data and close
         //producer.close();

    }
}
