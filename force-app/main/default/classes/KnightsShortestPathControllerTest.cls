@isTest
public with sharing class KnightsShortestPathControllerTest {
    @isTest
    public static void getShortestPathTest() {
        KnightsShortestPathController knightController = new KnightsShortestPathController();
        knightController.inputPositions ='D4 D5';
        knightController.getShortestPath();
        System.assertEquals('D4 E2 F4 D5', knightController.outputPositions,'Wrong Result');


    }
}