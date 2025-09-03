import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.size = 32.0,
    this.spacing = 16.0,
  }) : super(key: key);

  final int currentStep;
  final int totalSteps;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final stepNumber = index + 1;
          final isCompleted = stepNumber < currentStep;
          final isActive = stepNumber == currentStep;
          final isUpcoming = stepNumber > currentStep;
          
          return Expanded(
            child: Row(
              children: [
                // Step Circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted 
                        ? theme.colorScheme.primary
                        : isActive 
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceVariant,
                    border: Border.all(
                      color: isActive 
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check_rounded,
                          color: theme.colorScheme.onPrimary,
                          size: size * 0.6,
                        )
                      : Center(
                          child: Text(
                            stepNumber.toString(),
                            style: TextStyle(
                              color: isActive 
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: size * 0.4,
                            ),
                          ),
                        ),
                ),
                
                // Connection Line (except for last step)
                if (index < totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.symmetric(horizontal: spacing / 2),
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
